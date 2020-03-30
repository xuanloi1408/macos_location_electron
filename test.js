const weatherServiceRunner = () => {
    const { getCurrentPosition } = require('./src/index');

    console.log('test.js < Line: 4 > ===> ' + getCurrentPosition);
    
    function successCallback(position) {
        
    }

    function errorCallback(err) {
        alert(`ERROR(${err.code}): ${err.message}`);
    }

    // eslint-disable-next-line no-undef
    getCurrentPosition(successCallback, errorCallback);

};

weatherServiceRunner();