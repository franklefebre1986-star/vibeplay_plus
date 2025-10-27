import express from "express";
import fetch from "node-fetch";

const app = express();

app.get("/proxy", async (req, res) => {
  const target = req.query.url;
  if (!target) return res.status(400).send("Missing url");

  try {
    const response = await fetch(target, {
      headers: {
        "User-Agent": "VLC/3.0.16",
        "Referer": "https://line.nero-ott.link",
        "Origin": "https://line.nero-ott.link"
      }
    });
    res.set("Access-Control-Allow-Origin", "*");
    response.body.pipe(res);
  } catch (e) {
    res.status(500).send("Proxy error: " + e.message);
  }
});

app.listen(8080, () => console.log("✅ Proxy draait op http://localhost:8080"));
