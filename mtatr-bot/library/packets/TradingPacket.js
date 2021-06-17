"use strict";

const Packet = require("./Packet");

class TradingPacket extends Packet {
    constructor(payload = {}) {
        super();
        this.type = "trading.vehicle";
        this.payload = payload;
    }

    static success_vehicle(msg_id, owner_id, vehicle_uuid) {
        return new TradingPacket({ "success": true, "message_id": msg_id, "owner_id": owner_id, "vehicle_uuid": vehicle_uuid});
    }

    static wait() {
        return new TradingPacket({ "success": true, "wait": true })
    }

    /**
     * @param {string} [eror]
     */
    static error(error = "") {
        return new TradingPacket({ "success": false, "error": error });
    }
}

module.exports = TradingPacket;
