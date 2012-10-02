/*
    Static members of goog object
    EXPERIMENTAL
*/
interface Goog {

    require(name: string);
    provide(name: string);

}

declare var goog: Goog;