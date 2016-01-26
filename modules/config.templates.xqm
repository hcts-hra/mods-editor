xquery version "3.0";

module namespace config = "http://hra.uni-heidelberg.de/ns/mods-editor/config/";

(:~ various paths :)
(:declare variable $config:app-root := "/db/apps/hra-mods-editor";:)
declare variable $config:app-path := "/db/apps/tamboti/modules/edit";
declare variable $config:data-path := "/db/data";

(:~ credentials for the dba admin user :)
declare variable $config:dba-credentials := ("admin", "");

(:~ various permissions :)
declare variable $config:resource-mode := "rw-------";
