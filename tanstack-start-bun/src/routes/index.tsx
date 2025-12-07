import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/")({
  component: Home,
});

function Home() {
  const subtitle = "Performance testing with TanStack Start and Bun";

  return (
    <>
      <header className="header">
        <a
          href="https://tanstack.com/start"
          target="_blank"
          rel="noopener noreferrer"
        >
          Docs
        </a>
        <a
          href="https://github.com/TanStack/router"
          target="_blank"
          rel="noopener noreferrer"
        >
          GitHub
        </a>
      </header>
      <div className="title-wrap">
        <h1 className="title">
          TAN<span>STACK</span> START
        </h1>
        <div className="logo">
          <img src="/rust.svg" className="rust" alt="Rust logo" />
          <img src="/react.svg" className="react" alt="React logo" />
        </div>
      </div>
      <div className="subtitle-wrap">
        <p className="subtitle">{subtitle}</p>
        <a
          href="https://bun.sh"
          target="_blank"
          rel="noopener noreferrer"
          className="button"
          type="button"
        >
          Powered by Bun
        </a>
      </div>
    </>
  );
}
