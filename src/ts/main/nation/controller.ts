import * as bus from "../infra/bus";
import * as store from "../infra/store";
import * as nation from "./domain";

export const init = () => {
    bus.on("citizenLeft", id => {
        nation.radiate(id, store.getNation())
            .onSuccess(ok => store.update(ok))
            .onError(error => console.error(`unable to radiate citizen: ${error}`));
        bus.publishFront("citizenLeft", id);
    });
}