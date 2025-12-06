import { Handlers, PageProps } from "$fresh/server.ts";

interface Data {
  subtitle: string;
}

export const handler: Handlers<Data> = {
  async GET(_req, ctx) {
    const data: Data = {
      subtitle: "The react / rust fullstack framework",
    };
    return ctx.render(data);
  },
};

export default function Home({ data }: PageProps<Data>) {
  return (
    <>
      <header class="header">
        <a href="https://crates.io/crates/tuono" target="_blank">
          Crates
        </a>
        <a href="https://www.npmjs.com/package/tuono" target="_blank">
          Npm
        </a>
      </header>
      <div class="title-wrap">
        <h1 class="title">
          TU<span>O</span>NO
        </h1>
        <div class="logo">
          <img src="/rust.svg" class="rust" alt="Rust logo" />
          <img src="/react.svg" class="react" alt="React logo" />
        </div>
      </div>
      <div class="subtitle-wrap">
        <p class="subtitle">{data.subtitle}</p>
        <a
          href="https://github.com/tuono-labs/tuono"
          target="_blank"
          class="button"
        >
          Github
        </a>
      </div>
    </>
  );
}
