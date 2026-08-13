// Proxies MyAnimeList's "get user anime list" endpoint (same CORS problem as
// the token endpoint — api.myanimelist.net doesn't allow direct browser
// calls). Follows pagination server-side so the browser gets the full list
// in one response. Read-only: this never writes anything back to MAL.
exports.handler = async (event) => {
  if (event.httpMethod !== 'GET') {
    return { statusCode: 405, body: 'Method Not Allowed' };
  }

  const authHeader = event.headers.authorization || event.headers.Authorization;
  if (!authHeader) {
    return { statusCode: 401, body: JSON.stringify({ error: 'Missing Authorization header.' }) };
  }

  const clientId = process.env.MAL_CLIENT_ID;
  if (!clientId) {
    return { statusCode: 500, body: JSON.stringify({ error: 'Server is missing MAL_CLIENT_ID configuration.' }) };
  }

  const headers = { Authorization: authHeader, 'X-MAL-Client-ID': clientId };
  let url = 'https://api.myanimelist.net/v2/users/@me/animelist?fields=list_status&limit=1000&nsfw=true';
  const data = [];

  try {
    for (let page = 0; page < 20 && url; page++) {
      const res = await fetch(url, { headers: headers });
      if (!res.ok) {
        const text = await res.text();
        return { statusCode: res.status, headers: { 'Content-Type': 'application/json' }, body: text };
      }
      const json = await res.json();
      data.push.apply(data, json.data || []);
      url = json.paging && json.paging.next ? json.paging.next : null;
    }
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ data: data })
    };
  } catch (err) {
    return {
      statusCode: 502,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Failed to reach MyAnimeList.', detail: String(err) })
    };
  }
};
