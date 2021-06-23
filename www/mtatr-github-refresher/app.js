const express = require('express');
const app = express();
const port = 8201;
const MTAClient = require('mtasa').Client;
const mta = new MTAClient(process.env.MTA_HOST, process.env.MTA_PORT, process.env.MTA_HTTP_USER, process.env.MTA_HTTP_PASSWORD);

app.get('/', (req, res) => {
    res.send('App works.');
});

app.get('/trigger-refreshall', async (req, res) => {
    try {
        const result = await mta.resources.github_refresh_receiver.triggerRefreshAll();
        if (result == true) {
            res.statusCode = 200;
            res.send(JSON.stringify(result));
        } else {
            res.statusCode = 400;
            res.send(`[Error] MTA Server returned ${result}`);
        }
    } catch (err) {
        res.send(`Ooops! Something went wrong ${err}`);
        console.error(`Ooops! Something went wrong ${err}`);
    }
});

app.listen(port, () => {
    console.log(`[GITHUB-REFRESHER] listening at http://localhost:${port}`);
})
