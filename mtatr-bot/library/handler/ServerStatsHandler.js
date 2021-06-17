"use strict";

const Handler = require("./Handler");

class ServerStatsHandler extends Handler {
    constructor() {
        super();
        this.types.add("serverstats.countandname");
        this.types.add("serverstats.players");
        this.types.add("serverstats.debugmessage");
    }

    execute(bot, session, type, payload) {
        if (type == "serverstats.countandname") {
            if (payload.name == null) {
                console.log(`serverstats.countandname cannot continue, 'payload.name' was not set ${payload.name}`);
                return;
            }
            if (payload.count == null) {
                console.log(`serverstats.countandname cannot continue, 'payload.count' was not set ${payload.count}`);
                return;
            }
            if (payload.max_count == null) {
                console.log(`serverstats.countandname cannot continue, 'payload.max_count' was not set ${payload.max_count}`);
                return;
            }

            console.log(`Server stats:`);
            console.log(JSON.stringify(payload));
            let count = this.escape(payload.count);
            let max_count = this.escape(payload.max_count);
            let name = this.escape(payload.name);
            name = name == 'MTA:SA' ? 'GÜNLÜK ETKİNLİKLER GÖREVLER VE DAHA FAZLASI' : name;
            bot.setChannelStatus(`${name} :mouse_three_button: ${count}/${max_count}`)
                .then(updated => {
                    console.log('updated channel topic:');
                    console.log(`${updated}`);
                })
                .catch(() => console.error("bot.setChannelStatus error @ ServerStatsHandler.js#23"));
        } else if (type == "serverstats.players") {
            if (!payload.players)
                return;
            const playersToStr = payload.players.join('\n');
            const playersStr = "```\n" + playersToStr + "\n```";
            const embed = {
                embed: {
                    color: 3447003,
                    author: {
                        name: bot.username,
                        icon_url: bot.avatarURL
                    },
                    title: `There are currently **${payload.players.length}** players in game`,
                    description: playersStr,
                    timestamp: new Date(),
                }
            }
            if (bot && bot.channel) {
                bot.channel.fetchMessages().then(messages => {
                    if (messages.size > 0) {
                        const first = messages.first();
                        if (first !== null) {
                            first.edit(embed);
                            return true;
                        }
                    }
                    bot.sendMessage(embed);
                })
                    .catch(err => {
                        console.log('Error while getting mentions: ');
                        console.log(err);
                    });
            }
        } else if (type == "serverstats.debugmessage") {
            if (!payload.message)
                return;
            bot.sendMessage(payload.message);
        }
    }

    escapeMarkdown(text) {
        var unescaped = text.replace(/\\(\*|_|`|~|\\)/g, '$1'); // unescape any "backslashed" character
        var escaped = unescaped.replace(/(\*|_|`|~|\\)/g, '\\$1'); // escape *, _, `, ~, \
        return escaped;
    }
}

module.exports = ServerStatsHandler;
