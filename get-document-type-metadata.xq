xquery version "3.0";

import module namespace config = "http://hra.uni-heidelberg.de/ns/mods-editor/config/" at "modules/config.xqm";

declare namespace mods-editor = "http://hra.uni-heidelberg.de/ns/mods-editor/";

let $data-template-name := request:get-parameter('data-template-name', '')


return doc(concat($config:app-path, '/code-tables/document-type.xml'))//mods-editor:item[mods-editor:value eq $data-template-name]
