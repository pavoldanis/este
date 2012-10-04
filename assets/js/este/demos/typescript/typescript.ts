/// <reference path="typescript.d.ts" />
//goog.provide("este.demos.typescript.Greeter");

module este.demos.typescript {
  export class Greeter {
    greeting: string;
      constructor (message: string) {
        this.greeting = message;
    }
    greet() {
        return "Hello, " + this.greeting;
    }
  }
}