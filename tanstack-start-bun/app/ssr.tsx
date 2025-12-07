import {
  StartClient,
  defaultTransformer,
  createStartHandler,
} from "@tanstack/start";
import { createRouter } from "./router";

const router = createRouter();

if (typeof document !== "undefined") {
  StartClient({ router });
}

export const handler = createStartHandler({
  createRouter,
  transformer: defaultTransformer,
});
