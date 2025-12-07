import { rootRouteWithContext, RootRoute } from "@tanstack/react-router";

const rootRoute = rootRouteWithContext()({
  id: "__root",
});

const indexRoute = new RootRoute({
  id: "/",
  path: "/",
});

export const routeTree = rootRoute.addChildren([indexRoute]);
