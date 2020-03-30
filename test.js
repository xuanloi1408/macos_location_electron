const weatherServiceRunner = () => {
    const { getCurrentPosition } = require('./src/index');

    function successCallback(position) {
        console.log(`LOCATION:` + JSON.stringify(position));
    }

    function errorCallback(err) {
        console.log(`ERROR(${err.code}): ${err.message}`);
    }

    // eslint-disable-next-line no-undef
    getCurrentPosition(successCallback, errorCallback);

};

weatherServiceRunner();