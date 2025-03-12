const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Secure CI/CD Pipeline is Running!");
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
