xquery version "3.0";

import module namespace config = "http://exist-db.org/mods/config" at "modules/config.xqm";
import module namespace installation = "http://hra.uni-heidelberg.de/ns/tamboti/installation/" at "xmldb:exist:///db/apps/tamboti/modules/installation/installation.xqm";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

declare variable $config-collection := "/system/config";

declare variable $editor-code-tables-collection := "/db/apps/tamboti/modules/edit/code-tables";

installation:mkcol($config-collection, $editor-code-tables-collection, $config:public-collection-mode)
,
xmldb:store-files-from-pattern(fn:concat($config-collection, $editor-code-tables-collection), $dir, "system/*.xconf")
