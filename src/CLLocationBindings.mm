#include <math.h>
#include <node.h>
#include <v8.h>

#import "LocationManager.h"

using namespace v8;
using namespace node;

void getCurrentPosition(const FunctionCallbackInfo<Value>& args) {
  Isolate* isolate = args.GetIsolate();
  HandleScope scope(isolate);

  LocationManager* locationManager = [[LocationManager alloc] init];

  // if (args.Length() == 1) {
  //   if (args[0]->IsObject()) {
  //     Local<Object> options = args[0]->ToObject(isolate->GetCurrentContext()).ToLocalChecked();
  //     Local<String> maximumAgeKey = String::NewFromUtf8(isolate, "maximumAge", NewStringType::kNormal).ToLocalChecked();
  //     if (options->Has(isolate->GetCurrentContext(),maximumAgeKey).ToChecked() ) {
  //       locationManager.maximumAge = fmax(
  //         100, (options->Get(isolate->GetCurrentContext(), maximumAgeKey)).ToLocalChecked()
  //       );
  //       locationManager.maximumAge /= 1000.0;
  //     }

  //     Local<String> enableHighAccuracyKey = String::NewFromUtf8(
  //       isolate, "enableHighAccuracy", NewStringType::kNormal).ToLocalChecked();
  //     if (options->Has(isolate->GetCurrentContext(), enableHighAccuracyKey).ToChecked()) {
  //       locationManager.enableHighAccuracy = (options->Get(
  //         isolate->GetCurrentContext(),
  //         enableHighAccuracyKey
  //       )).ToLocalChecked();
  //     }

  //     Local<String> timeout = String::NewFromUtf8(
  //       isolate, "timeout", NewStringType::kNormal).ToLocalChecked();
  //     if (options->Has(isolate->GetCurrentContext(), timeout).ToChecked()) {
  //       locationManager.timeout = (options->Get(isolate->GetCurrentContext(), timeout)).ToLocalChecked()->NumberValue();
  //     }
  //   }
  // }

  if (![CLLocationManager locationServicesEnabled]) {
    isolate->ThrowException(
      Exception::TypeError(
        String::NewFromUtf8(isolate, "CLocationErrorNoLocationService", NewStringType::kNormal).ToLocalChecked()
      )
    );
    return;
  }

  CLLocation* location = [locationManager getCurrentLocation];

  if ([locationManager hasFailed]) {
    switch (locationManager.errorCode) {
      case kCLErrorDenied:
        isolate->ThrowException(
            Exception::TypeError(
              String::NewFromUtf8( isolate, "CLocationErrorLocationServiceDenied", NewStringType::kNormal).ToLocalChecked()
            )
        );
        return;
      case kCLErrorGeocodeCanceled:
        isolate->ThrowException(
            Exception::TypeError(
              String::NewFromUtf8(isolate, "CLocationErrorGeocodeCanceled", NewStringType::kNormal).ToLocalChecked()
            )
        );
        return;
      case kCLErrorLocationUnknown:
        isolate->ThrowException(
            Exception::TypeError(
              String::NewFromUtf8(isolate, "CLocationErrorLocationUnknown", NewStringType::kNormal).ToLocalChecked()
            )
        );
        return;
      default:
        isolate->ThrowException(
            Exception::TypeError(
              String::NewFromUtf8(isolate, "CLocationErrorLookupFailed", NewStringType::kNormal).ToLocalChecked()
            )
        );
        return;
      }
  }

  Local<Object> obj = Object::New(isolate);
  obj->Set(
    isolate->GetCurrentContext(),
    String::NewFromUtf8(isolate, "latitude", NewStringType::kNormal).ToLocalChecked(),
    Number::New(isolate, location.coordinate.latitude)
  );
  obj->Set(
    isolate->GetCurrentContext(),
    String::NewFromUtf8(isolate, "longitude", NewStringType::kNormal).ToLocalChecked(),
    Number::New(isolate, location.coordinate.longitude)
  );
  obj->Set(
    isolate->GetCurrentContext(),
    String::NewFromUtf8(isolate, "altitude", NewStringType::kNormal).ToLocalChecked(),
    Number::New(isolate, location.altitude)
  );
  obj->Set(
    isolate->GetCurrentContext(),
    String::NewFromUtf8(isolate, "horizontalAccuracy", NewStringType::kNormal).ToLocalChecked(),
    Number::New(isolate, location.horizontalAccuracy)
  );
  obj->Set(
    isolate->GetCurrentContext(),
    String::NewFromUtf8(isolate, "verticalAccuracy", NewStringType::kNormal).ToLocalChecked(),
    Number::New(isolate, location.verticalAccuracy)
  );

  NSTimeInterval seconds = [location.timestamp timeIntervalSince1970];
  obj->Set(
    isolate->GetCurrentContext(),
    String::NewFromUtf8(isolate, "timestamp", NewStringType::kNormal).ToLocalChecked(),
    Number::New(isolate, (NSInteger)ceil(seconds * 1000))
  );

  args.GetReturnValue().Set(obj);
}

void Initialise(v8::Local<Object> exports) {
  NODE_SET_METHOD(exports, "getCurrentPosition", getCurrentPosition);
}

NODE_MODULE(macos_clocation_wrapper, Initialise)
