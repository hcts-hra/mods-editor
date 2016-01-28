xquery version "3.0";

declare variable $exist:controller external;
declare variable $exist:root external;
declare variable $exist:prefix external;
declare variable $exist:path external;
declare variable $exist:resource external;

(: if we have a slash or a null then redirect to the index page. :)
if ($exist:path eq '/')
    then
        (: forward root path to index.xq :)
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="edit.xq"/>
        </dispatch>
    else
        (: everything else is passed through :)
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <cache-control cache="yes"/>
        </dispatch>
        