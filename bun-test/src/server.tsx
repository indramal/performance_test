import { renderToString } from "react-dom/server";
import App from "./components/App";
import "./styles/global.css";

const PORT = 3001;

// API data endpoint
const getData = () => ({
  subtitle: "The react / rust fullstack framework",
});

// HTML template
const htmlTemplate = (content: string, styles: string) => `
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bun SSR Test</title>
    <link rel="icon" href="/favicon.ico">
    <style>${styles}</style>
  </head>
  <body>
    <main>${content}</main>
  </body>
</html>
`;

// Read CSS file
const cssContent = await Bun.file("./src/styles/global.css").text();

const server = Bun.serve({
  port: PORT,
  fetch(req) {
    const url = new URL(req.url);

    // API endpoint
    if (url.pathname === "/api/data") {
      return new Response(JSON.stringify(getData()), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // Static files
    if (url.pathname.startsWith("/")) {
      const filePath = `./public${url.pathname}`;
      const file = Bun.file(filePath);

      if (file.size > 0) {
        return new Response(file);
      }
    }

    // SSR homepage
    if (url.pathname === "/") {
      const data = getData();
      const html = renderToString(<App subtitle={data.subtitle} />);
      const fullHtml = htmlTemplate(html, cssContent);

      return new Response(fullHtml, {
        headers: { "Content-Type": "text/html" },
      });
    }

    return new Response("Not Found", { status: 404 });
  },
});

console.log(`Bun server running at http://localhost:${PORT}`);
