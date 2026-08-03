/**
 * Cloudflare Pages Function — серверное проксирование RSS-ленты.
 *
 * Маршрут: GET /api/rss
 *
 * Зачем: раньше гостевая лента запрашивалась из браузера через публичный
 * прокси allorigins.win. Прокси не дожидался ответа FeedBurner (HTTP 522,
 * ~20 с), возвращал страницу ошибки без Access-Control-Allow-Origin, и
 * браузер блокировал ответ (net::ERR_FAILED). Здесь fetch выполняется на
 * сервере: CORS не участвует (endpoint same-origin), публичные прокси не
 * нужны, у апстрима есть жёсткий таймаут, а ответ кэшируется на edge.
 *
 * Локальная проверка: `npm run build && npx wrangler pages dev dist`
 * (в `vite dev` функции нет — клиент автоматически уходит на резервных
 * провайдеров из цепочки в src/app/App.tsx).
 */

const FEED_URL = "https://feeds.feedburner.com/rsscna/engnews/";
const UPSTREAM_TIMEOUT_MS = 8000;
const CACHE_CONTROL = "public, max-age=300, s-maxage=1800, stale-while-revalidate=600";

function baseHeaders(): Record<string, string> {
  return {
    // Запросы приходят с того же origin, но заголовок оставляем явно —
    // тогда ответ безопасно читать и при прямых проверках endpoint'а.
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Max-Age": "86400",
    "X-Content-Type-Options": "nosniff",
  };
}

function errorResponse(status: number, code: string, message: string): Response {
  return new Response(JSON.stringify({ ok: false, error: { code, message } }), {
    status,
    headers: {
      ...baseHeaders(),
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store",
    },
  });
}

interface PagesFunctionContext {
  request: Request;
}

export async function onRequestGet(_context: PagesFunctionContext): Promise<Response> {
  let upstream: Response;

  try {
    upstream = await fetch(FEED_URL, {
      headers: {
        // FeedBurner отбивает анонимных агрегаторов без User-Agent.
        "User-Agent": "GlassWave RSS reader (+https://glasswave.pages.dev)",
        Accept: "application/rss+xml, application/atom+xml, application/xml;q=0.9, text/xml;q=0.9",
      },
      signal: AbortSignal.timeout(UPSTREAM_TIMEOUT_MS),
      // Кэш на edge Cloudflare: повторные запросы не ходят к FeedBurner
      // и не упираются в его rate-limit.
      cf: { cacheEverything: true, cacheTtl: 300 },
    } as RequestInit);
  } catch (error) {
    const timedOut = error instanceof Error && (error.name === "TimeoutError" || error.name === "AbortError");
    return timedOut
      ? errorResponse(504, "upstream_timeout", `FeedBurner не ответил за ${UPSTREAM_TIMEOUT_MS} мс.`)
      : errorResponse(502, "upstream_unreachable", "Не удалось установить соединение с FeedBurner.");
  }

  if (!upstream.ok) {
    return errorResponse(502, "upstream_http_error", `FeedBurner ответил HTTP ${upstream.status}.`);
  }

  const body = await upstream.text();
  if (!/<rss[\s>]|<feed[\s>]/i.test(body)) {
    return errorResponse(502, "upstream_invalid_payload", "Ответ апстрима не похож на RSS/Atom-ленту.");
  }

  return new Response(body, {
    status: 200,
    headers: {
      ...baseHeaders(),
      "Content-Type": "application/rss+xml; charset=utf-8",
      "Cache-Control": CACHE_CONTROL,
    },
  });
}

export function onRequestOptions(): Response {
  return new Response(null, { status: 204, headers: baseHeaders() });
}
