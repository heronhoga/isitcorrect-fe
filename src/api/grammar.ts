const APP_KEY = import.meta.env.VITE_APP_KEY;
const BACKEND_URL = import.meta.env.VITE_BACKEND_URL;

export async function checkGrammarAPI(text: string) {
  const response = await fetch(`${BACKEND_URL}/check`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-APP-KEY': `${APP_KEY}`,
    },
    body: JSON.stringify({ text }),
  });

  const data = await response.json();

  return data;
}