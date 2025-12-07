import { createFileRoute } from "@tanstack/react-router";
import { createServerFn } from "@tanstack/start";

const getSubtitle = createServerFn("GET", async () => {
  return { subtitle: "The react / rust fullstack framework" };
});

export const Route = createFileRoute("/")({
  component: Home,
  loader: async () => await getSubtitle(),
});

function Home() {
  const data = Route.useLoaderData();

  return (
    <>
      <header className="header">
        <a href="https://crates.io/crates/tuono" target="_blank">
          Crates
        </a>
        <a href="https://www.npmjs.com/package/tuono" target="_blank">
          Npm
        </a>
      </header>
      <div className="title-wrap">
        <h1 className="title">
          TU<span>O</span>NO
        </h1>
        <div className="logo">
          <img src="/rust.svg" className="rust" alt="Rust logo" />
          <img src="/react.svg" className="react" alt="React logo" />
        </div>
      </div>
      <div className="subtitle-wrap">
        <p className="subtitle">{data.subtitle}</p>
        <a
          href="https://github.com/tuono-labs/tuono"
          target="_blank"
          className="button"
          type="button"
        >
          Github
        </a>
      </div>
    </>
  );
}
