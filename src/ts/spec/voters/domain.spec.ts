import {empty, enlist, Guest, Voters} from "../../main/voters/domain";

describe("Voters", () => {
   describe("Enlist", () => {
      it("a guest can enlist", () => {
         let now = new Date();
         enlist(new Guest("1", "toto"), empty, now)
             .onSuccess(ok => expect(ok[1].keys()).toContain("1"))
             .onError(error => fail(error));
      });
      it("name is unique", () => {
         let now = new Date();
         enlist(new Guest("1", "toto"), empty, now)
             .flatMap(ok => enlist(new Guest("2", "toto"), ok[1], now))
             .onSuccess(_ => fail("Should have failed"))
             .onError(error => expect(error).toEqual("Name is already taken"));
      });
   });
});
