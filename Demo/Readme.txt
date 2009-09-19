This very simple demo shows you all the Emballo features.
You will see:
  * Injection ocurring into non interface objects (IGreetingService being injected into
    TGreetingForm).

  * Nested injections (ITimeService being injected into IGreetingService which is injected
    into TGreetingForm).

  * Different strategies for configuring the injection:
    1. Registering a subclass of TInjectable (TTimeServiceImpl)
    2. Registering an arbitrary class with its constructor address (TGreetingServiceImpl)
    3. Registering a pre built instance (TMockTimeService)