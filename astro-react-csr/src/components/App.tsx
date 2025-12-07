import { useState, useEffect } from "react";
import "../styles/global.css";

export default function App() {
  const [subtitle, setSubtitle] = useState("");
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Simulate data fetching
    setTimeout(() => {
      setSubtitle("The react / rust fullstack framework");
      setIsLoading(false);
    }, 0);
  }, []);

  if (isLoading) {
    return <h1>Loading...</h1>;
  }

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
        <p className="subtitle">{subtitle}</p>
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
