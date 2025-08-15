const API_BASE = 'http://localhost:3000/api';

function getToken() {
  return JSON.parse(localStorage.getItem('user'))?.token;
}

async function request(method, url, data) {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
  const opts = {
    method,
    headers,
    ...(data ? { body: JSON.stringify(data) } : {}),
  };
  const res = await fetch(`${API_BASE}${url}`, opts);
  const json = await res.json();
  if (!res.ok) throw new Error(json.message || 'API error');
  return json;
}

export const api = {
  get: (url) => request('GET', url),
  post: (url, data) => request('POST', url, data),
  put: (url, data) => request('PUT', url, data),
  del: (url) => request('DELETE', url),
  patch: (url, data) => request('PATCH', url, data),
  baseURL: API_BASE,
  upload: async (url, formData) => {
    const token = getToken();
    const headers = {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    };
    const opts = {
      method: 'POST',
      headers,
      body: formData,
    };
    const res = await fetch(`${API_BASE}${url}`, opts);
    const json = await res.json();
    if (!res.ok) throw new Error(json.message || 'API error');
    return json;
  },
  uploadPut: async (url, formData) => {
    const token = getToken();
    const headers = {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    };
    const opts = {
      method: 'PUT',
      headers,
      body: formData,
    };
    const res = await fetch(`${API_BASE}${url}`, opts);
    const json = await res.json();
    if (!res.ok) throw new Error(json.message || 'API error');
    return json;
  }
}; 