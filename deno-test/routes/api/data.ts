import { Handlers } from "$fresh/server.ts";

export const handler: Handlers = {
  GET(_req) {
    return new Response(
      JSON.stringify({
        subtitle: "The react / rust fullstack framework",
      }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  },
};
