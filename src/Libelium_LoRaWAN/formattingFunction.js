function decodeUplink(input) {
    // Convert the inputs byte into a ASCII String
    var asciiString = String.fromCharCode.apply(null, input.bytes);
    // Split the string with # as a delimiter
    var splitString = asciiString.split("#");
    var waspMoteId = splitString[2];
    var messageNumber = splitString[3];
    var batteryLevel = splitString[4].split(":")[1];
    var watermark = splitString[5].split(":")[1];
    var temperatureSoil = splitString[6].split(":")[1];
    var temperatureAir = splitString[7].split(":")[1];
    var humidity = splitString[8].split(":")[1];
    var pressure = splitString[9].split(":")[1];
    return {
        data: {
            waspMoteId: waspMoteId,
            time: new Date(),
            messageNumber: messageNumber,
            batteryLevel: batteryLevel,
            watermark: watermark,
            temperatureSoil: temperatureSoil,
            temperatureAir: temperatureAir,
            humidity: humidity,
            pressure: pressure,
        },
        warnings: [],
        errors: [],
    };
}
