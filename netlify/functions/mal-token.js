// Proxies the MyAnimeList OAuth2 token endpoint. This exists because
// myanimelist.net's token endpoint doesn't send CORS headers, so a browser
// can't call it directly — not because of a secret that needs hiding (an app
// registered as type "Other" has no client_secret at all).
exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method Not Allowed' };
  }

  let payload;
  try {
    payload = JSON.parse(event.body || '{}');
  } catch (err) {
    return { statusCode: 400, body: JSON.stringify({ error: 'Invalid JSON body.' }) };
  }

  const clientId = process.env.MAL_CLIENT_ID;
  const clientSecret = process.env.MAL_CLIENT_SECRET || '';
  if (!clientId) {
    return { statusCode: 500, body: JSON.stringify({ error: 'Server is missing MAL_CLIENT_ID configuration.' }) };
  }

  const params = new URLSearchParams();
  params.set('client_id', clientId);
  if (clientSecret) params.set('client_secret', clientSecret);

  if (payload.grant_type === 'refresh_token') {
    if (!payload.refresh_token) {
      return { statusCode: 400, body: JSON.stringify({ error: 'Missing refresh_token.' }) };
    }
    params.set('grant_type', 'refresh_token');
    params.set('refresh_token', payload.refresh_token);
  } else {
    if (!payload.code || !payload.code_verifier || !payload.redirect_uri) {
      return { statusCode: 400, body: JSON.stringify({ error: 'Missing code, code_verifier, or redirect_uri.' }) };
    }
    params.set('grant_type', 'authorization_code');
    params.set('code', payload.code);
    params.set('code_verifier', payload.code_verifier);
    params.set('redirect_uri', payload.redirect_uri);
  }

  try {
    const res = await fetch('https://myanimelist.net/v1/oauth2/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    });
    const text = await res.text();
    return {
      statusCode: res.status,
      headers: { 'Content-Type': 'application/json' },
      body: text
    };
  } catch (err) {
    return {
      statusCode: 502,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Failed to reach MyAnimeList.', detail: String(err) })
    };
  }
};
