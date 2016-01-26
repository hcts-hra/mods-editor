xquery version "3.0";

module namespace config = "http://hra.uni-heidelberg.de/ns/mods-editor/config/";

declare namespace mods = "http://www.loc.gov/mods/v3";

(:~ various paths :)
(:declare variable $config:app-root := "/db/apps/hra-mods-editor";:)
declare variable $config:app-path := "/db/apps/tamboti/modules/edit";
declare variable $config:data-path := "/db/data";

(:~ credentials for the dba admin user :)
declare variable $config:dba-credentials := ("admin", "");

(:~ various permissions :)
declare variable $config:resource-mode := "rw-------";

declare function config:get-short-title($entry as element()) {
    (: If the entry has a related item of @type host with an extent in part, it is a periodical article or a contribution to an edited volume and the title should be enclosed in quotation marks. :)
    (: In order to avoid having to iterate through the (extremely rare) instances of multiple elements and in order to guard against cardinality errors in faulty records duplicating elements that are supposed to be unique, a lot of filtering for first child is performed. :)
    
    (: The short title only consists of the main title, which is untyped, and its renditions in transliteration and translation. 
    Filter away the remaining titleInfo @type values. 
    This means that a record without an untyped titleInfo will not display any title. :)
    let $titleInfo := $entry/mods:titleInfo[not(@type = ('abbreviated', 'uniform', 'alternative'))]
    
    (: The main title can be 1) in original language and script, or 2) in transliteration, or 3) in translation. 
    Therefore, split titleInfo into these three, reusing $titleInfo for the untyped titleInfo. 
    Since "transliterated" is not a valid value for @type, we have to deduce the existence of a transliterated titleInfo from the fact that it contains @transliteration. 
    Since the Tamboti editor operates with a global setting for transliteration (in extension), 
    it is necessary to mark a transliterated titleInfo in the instances by means of an empty @transliteration. 
    Since in MODS, a transliterated titleInfo has the @type value "translated", we check for this as well. 
    Hence a titleInfo with @type "translated" with be a translation if it has no @transliteration (empty or not); otherwise it will be a transliteration.
    A translated titleInfo ought to have a @lang, but it is not necessary to check for this. :)
    (: NB: Parsing this would be a lot easier if MODS accepted "transliterated" as value for @type on titleInfo. :)
    (: NB: With 3.5 MODS accepts "transliterated" as value for @otherType on titleInfo. :)
    let $titleInfo-transliterated := $titleInfo[@transliteration][@type eq 'translated'][1]
    let $titleInfo-translated := $titleInfo[not(@transliteration)][@type eq 'translated'][1]
    let $titleInfo := $titleInfo[not(@type)][1]
    
    (: Split each of the three forms into their components. :)
    let $nonSort := $titleInfo/mods:nonSort[1]
    let $title := $titleInfo/mods:title[1]
    let $subTitle := $titleInfo/mods:subTitle[1]
    let $partNumber := $titleInfo/mods:partNumber[1]
    let $partName := $titleInfo/mods:partName[1]
    
    let $nonSort-transliterated := $titleInfo-transliterated/mods:nonSort[1]
    let $title-transliterated := $titleInfo-transliterated/mods:title[1]
    let $subTitle-transliterated := $titleInfo-transliterated/mods:subTitle[1]
    let $partNumber-transliterated := $titleInfo-transliterated/mods:partNumber[1]
    let $partName-transliterated := $titleInfo-transliterated/mods:partName[1]

    let $nonSort-translated := $titleInfo-translated/mods:nonSort[1]
    let $title-translated := $titleInfo-translated/mods:title[1]
    let $subTitle-translated := $titleInfo-translated/mods:subTitle[1]
    let $partNumber-translated := $titleInfo-translated/mods:partNumber[1]
    let $partName-translated := $titleInfo-translated/mods:partName[1]
        
    (: Format each of the three kinds of titleInfo. :)
    let $title-formatted := 
        concat(
        if (string($nonSort))
        (: NB: This assumes that nonSort is not used in Asian scripts; otherwise we would have to avoid the space by checking the language. :)
        then concat($nonSort, ' ' , $title)
        else $title
        , 
        if (string($subTitle)) 
        then concat(': ', $subTitle)
        else ()
        ,
        if (string($partNumber) or string($partName))
        then
            if (string($partNumber) and string($partName)) 
            then concat('. ', $partNumber, ': ', $partName)
            else
                if (string($partNumber))
                then concat('. ', $partNumber)
                else concat('. ', $partName)
                    
        else ()
        )
    let $title-formatted := concat('&lt;span>', $title-formatted, '&lt;/span>')
    let $title-formatted := util:parse-html($title-formatted)
    let $title-formatted := $title-formatted//*:span
    
    let $title-transliterated-formatted := 
        (
        if (string($nonSort-transliterated)) 
        then concat($nonSort-transliterated, ' ' , $title-transliterated)
        else $title-transliterated
        , 
        if (string($subTitle-transliterated)) 
        then concat(': ', $subTitle-transliterated)
        else ()
        ,
        if (string($partNumber-transliterated) or string($partName-transliterated))
        then
            if (string($partNumber-transliterated) and string($partName-transliterated)) 
            then concat('. ', $partNumber-transliterated, ': ', $partName-transliterated)
            else
                if (string($partNumber-transliterated))
                then concat('. ', $partNumber-transliterated)
                else concat('. ', $partName-transliterated)
        else ()
        )    
    let $title-transliterated-formatted := string-join($title-transliterated-formatted, '')
    
    let $title-translated-formatted := 
        (
        if (string($nonSort-translated)) 
        then concat($nonSort-translated, ' ' , $title-translated)
        else $title-translated
        , 
        if (string($subTitle-translated)) 
        then concat(': ', $subTitle-translated)
        else ()
        ,
        if (string($partNumber-translated) or string($partName-translated))
        then
            if (string($partNumber-translated) and string($partName-translated)) 
            then concat('. ', $partNumber-translated, ': ', $partName-translated)
            else
                if (string($partNumber-translated))
                then concat('. ', $partNumber-translated)
                else concat('. ', $partName-translated)
        else ()
        )
    let $title-translated-formatted := string-join($title-translated-formatted, '')
    
    (: Assemble the full short title to display. :)
    let $title :=
        ( 
        if ($title-transliterated)
        (: It is standard (at least in Sinology and Japanology) to first render the transliterated title, then the title in native script. :)
        then (<span xmlns="http://www.w3.org/1999/xhtml" class="title">{$title-transliterated-formatted}</span>, ' ')
        else ()
        , 
        if ($title-transliterated)
        (: If there is a transliterated title, the title in original script should not be italicised. :)
        then <span xmlns="http://www.w3.org/1999/xhtml" class="title-no-italics">{$title-formatted}</span>
        else
        (: If there is no transliterated title, the standard for Western literature. :)
            if (exists($entry/mods:relatedItem[@type eq 'host'][1]/mods:part/mods:extent) 
               or exists($entry/mods:relatedItem[@type eq 'host'][1]/mods:part/mods:detail/mods:number))
           then <span xmlns="http://www.w3.org/1999/xhtml" class="title-no-italics">“{$title-formatted}”</span>
           else <span xmlns="http://www.w3.org/1999/xhtml" class="title">{$title-formatted}</span>
        ,
        if ($title-translated)
        (: Enclose the translated title in parentheses. Titles of @type "translated" are always made by the cataloguer. 
        If a title is translated on the title page, it is recorded in a titleInfo of @type "alternative". :)
        then <span xmlns="http://www.w3.org/1999/xhtml" class="title-no-italics"> ({$title-translated-formatted})</span>
        else ()
        )
        return 
            if ($title != '')
            then $title
            else "<no title information>"
};