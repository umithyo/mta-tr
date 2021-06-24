"use strict";

const Handler = require("./Handler");
const TradingPacket = require("../packets/TradingPacket");
const IntlFormat = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumSignificantDigits: 3 });

class TradingHandler extends Handler {
    constructor() {
        super();
        this.types.add("trading.setvehicleforsale");
        this.types.add("trading.takevehiclefromsale");
        this.types.add("trading.soldvehicle");
        this.types.add("trading.getallvehicles");
        this.types.add("trading.registervehiclemessage");

        this.vehicle_icons = {
            "Automobile": ":blue_car:",
            "Plane": ":airplane:",
            "Bike": ":motorcycle:",
            "Helicopter": ":helicopter:",
            "Boat": ":motorboat:",
            "BMX": ":bike:",
            "Monster Truck": ":truck:",
            "Quad": ":motorbike:"
        };
    }

    execute(bot, session, type, payload) {
        if (type == "trading.getallvehicles") {
            const data = payload.data;
            data.forEach(vehicle => {
                // const embed = {
                //     embed: {
                //         color: 3447003,
                //         author: {
                //             name: bot.username,
                //             icon_url: bot.avatarURL
                //         },
                //         // url: 'mtasa://94.177.232.159:22004',
                //         title: `:blue_car: The **${vehicle.vehicle_name}** is now on sale!`,
                //         fields: [
                //             {
                //                 name: 'Owner',
                //                 value: this.escapeMarkdown(vehicle.owner_name),
                //                 inline: true
                //             },
                //             {
                //                 name: ':dollar:',
                //                 value: "$" + vehicle.sale_price,
                //                 inline: true
                //             },
                //         ],
                //         timestamp: new Date(),
                //         footer: {
                //             text: 'This data is synced.',
                //             icon_url: 'https://i.hizliresim.com/Rr5Dvd.png',
                //         },
                //     }
                // };
                const embed = `${this.vehicle_icons[vehicle.vehicle_type]} A(n) **${vehicle.vehicle_name}** is now for sale by **${this.escapeMarkdown(vehicle.owner_name)}** for **${IntlFormat.format(vehicle.sale_price)}**!`;
                if (vehicle.discord_message_id) {
                    bot.channel.fetchMessages({ around: vehicle.discord_message_id, limit: 1 }).then(messages => {
                        if (messages.size > 0) {
                            const first = messages.first();
                            if (first !== null) {
                                first.edit(embed);
                                return true;
                            }
                        } else {
                            console.log(vehicle.discord_message_id)
                            console.log(messages)
                            bot.sendMessage(embed).then(msg => {
                                console.log(msg.id);
                                console.log(vehicle)
                                session.send(TradingPacket.success_vehicle(msg.id, vehicle.owner_id, vehicle.uuid));
                            });
                        }
                    })
                        .catch(err => {
                            console.log('Error while getting mentions: ');
                            console.log(err);
                        });
                } else {
                    bot.sendMessage(embed).then(msg => {
                        console.log(msg.id);
                        console.log(vehicle)
                        session.send(TradingPacket.success_vehicle(msg.id, vehicle.owner_id, vehicle.uuid));
                    });
                }
            });
        } else if (type == "trading.registervehiclemessage") { //loading transaction as the waiting response
            const vehicle = payload;
            bot.sendMessage("Incoming transaction...").then(msg => {
                console.log(msg.id);
                console.log(vehicle)
                session.send(TradingPacket.success_vehicle(msg.id, vehicle.owner_id, vehicle.uuid));
            });
        } else if (type == "trading.setvehicleforsale") {
            const vehicle = payload;
            const embed = `${this.vehicle_icons[vehicle.vehicle_type]} A(n) **${vehicle.vehicle_name}** is now for sale by **${this.escapeMarkdown(vehicle.owner_name)}** for **${IntlFormat.format(vehicle.price)}**!`;
            if (vehicle.discord_message_id) {
                bot.channel.fetchMessages({ around: vehicle.discord_message_id, limit: 1 }).then(messages => {
                    if (messages.size > 0) {
                        const first = messages.first();
                        if (first !== null) {
                            first.edit(embed);
                            return true;
                        }
                    } else {
                        bot.sendMessage(embed).then(msg => {
                            console.log(msg.id);
                            console.log(vehicle)
                            session.send(TradingPacket.success_vehicle(msg.id, vehicle.owner_id, vehicle.vehicle_uuid));
                        });
                    }
                })
                    .catch(err => {
                        console.log('Error while getting mentions: ');
                        console.log(err);
                    });
            } else {
                bot.sendMessage(embed).then(msg => {
                    console.log(msg.id);
                    console.log(vehicle)
                    session.send(TradingPacket.success_vehicle(msg.id, vehicle.owner_id, vehicle.vehicle_uuid));
                });
            }
        }else if (type == "trading.takevehiclefromsale"){
            const vehicle = payload;
            const embed = `:red_circle: A(n) **${vehicle.vehicle_name}** is taken off of sale by **${this.escapeMarkdown(vehicle.owner_name)}.**`;
            if (vehicle.discord_message_id) {
                bot.channel.fetchMessages({ around: vehicle.discord_message_id, limit: 1 }).then(messages => {
                    if (messages.size > 0) {
                        const first = messages.first();
                        if (first !== null) {
                            first.edit(embed);
                            return true;
                        }
                    } else {
                        bot.sendMessage(embed).then(msg => {
                            console.log(msg.id, vehicle.owner_id);
                            session.send(TradingPacket.success_vehicle(msg.id, vehicle.owner_id, vehicle.vehicle_uuid));
                        });
                    }
                })
                    .catch(err => {
                        console.log('Error while getting mentions: ');
                        console.log(err);
                    });
            } else {
                bot.sendMessage(embed).then(msg => {
                    console.log(msg.id);
                    console.log(vehicle)
                    session.send(TradingPacket.success_vehicle(msg.id, vehicle.owner_id, vehicle.vehicle_uuid));
                });
            }
        }else if (type == "trading.soldvehicle"){
            const vehicle = payload;
            const embed = `:green_circle:  A(n) **${vehicle.vehicle_name}** has been sold to **${this.escapeMarkdown(vehicle.owner_name)}** by **${this.escapeMarkdown(vehicle.old_owner_name)}** for **${IntlFormat.format(vehicle.price)}**`;
            if (vehicle.discord_message_id) {
                bot.channel.fetchMessages({ around: vehicle.discord_message_id, limit: 1 }).then(messages => {
                    if (messages.size > 0) {
                        const first = messages.first();
                        if (first !== null) {
                            first.edit(embed);
                            return true;
                        }
                    } else {
                        bot.sendMessage(embed).then(msg => {
                            console.log(msg.id);
                            console.log(vehicle)
                            session.send(TradingPacket.success_vehicle(msg.id, vehicle.owner_id, vehicle.vehicle_uuid));
                        });
                    }
                })
                    .catch(err => {
                        console.log('Error while getting mentions: ');
                        console.log(err);
                    });
            } else {
                bot.sendMessage(embed).then(msg => {
                    console.log(msg.id);
                    console.log(vehicle)
                    session.send(TradingPacket.success_vehicle(msg.id, vehicle.owner_id, vehicle.vehicle_uuid));
                });
            }
        }
    }

    escapeMarkdown(text) {
        var unescaped = text.replace(/\\(\*|_|`|~|\\)/g, '$1'); // unescape any "backslashed" character
        var escaped = unescaped.replace(/(\*|_|`|~|\\)/g, '\\$1'); // escape *, _, `, ~, \
        return escaped;
    }
}

module.exports = TradingHandler;
