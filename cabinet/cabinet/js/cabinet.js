var _cabinet_state = {
     "openPanel":	null,
     "speed":		500,
     "processing":      null
    }



function togglePanel(panel)
{
  if (_cabinet_state.processing == null) {
    _cabinet_state.processing = panel;

    // No panel is currently open.

    if (_cabinet_state.openPanel == null) 
      {
      _cabinet_state.openPanel = panel;
      $("#ifm_panel_" + panel).attr('src',_cabinet_url[panel]);
      $('#cabinet_' + panel).css({'opacity':0.75});
      $('#cabinet_' + panel + ' span').hide();
      $("#panel_" + panel).slideDown({
        "duration": _cabinet_state.speed,
        "complete": function() {
          _cabinet_state.processing = null;
        }
      });
    }
  
    // User is closing the currently open panel.
  	
    else if (_cabinet_state.openPanel == panel) 
    {
      $("#ifm_panel_" + _cabinet_state.openPanel).attr('src','');
      $("#panel_" + _cabinet_state.openPanel).slideUp({
        "duration": _cabinet_state.speed,
        "complete": function() {
          $('#cabinet_' + _cabinet_state.openPanel).css({'opacity':1.0});
          $('#cabinet_' + _cabinet_state.openPanel + ' span').show();
          _cabinet_state.openPanel = null;
          _cabinet_state.processing = null;
        }
      });
    }
  
    // User is opening a different panel to the one currently displayed.
  
    else
    {
      $("#ifm_panel_" + _cabinet_state.openPanel).attr('src','');
      $("#panel_" + _cabinet_state.openPanel).slideUp({
        "duration": _cabinet_state.speed,
        "complete": function(){
          $('#cabinet_' + _cabinet_state.openPanel).css({'opacity':1.0});
          $('#cabinet_' + _cabinet_state.openPanel + ' span').show();
          _cabinet_state.openPanel = panel;
          $("#ifm_panel_" + panel).attr('src',_cabinet_url[panel]);
          $('#cabinet_' + panel).css({'opacity':0.75});
          $('#cabinet_' + panel + ' span').hide();
          $("#panel_" + panel).slideDown({
            "duration": _cabinet_state.speed,
            "complete": function() {
              _cabinet_state.processing = null;
            }
          });
        }
      });
    }
  }
}
	
