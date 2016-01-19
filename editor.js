modsEditor = {};

$(document).ready(function() {
    fluxProcessor.skipshutdown = true;
    
    $("#tabs-container").tabs({
        activate: function(event, ui) {
            $("div.subtabs", ui.newPanel).tabs("option", "active", 0);
            fluxProcessor.dispatchEventType("main-content", "loadSubform", {
                "subformId": $("div.subtabs li:first-child", ui.newPanel).attr('aria-controls')
            }); 
        },
        active: 0
    });
    $(".subtabs").tabs({
        activate: function(event, ui) {
            fluxProcessor.dispatchEventType("main-content", "loadSubform", {
                "subformId": ui.newTab.attr('aria-controls')
            });             
        }        
    });
  
  
});
