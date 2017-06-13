$(document).ready(function(){

  // 
  //  Select the first entry in the dropdown ("Choose a county")
  //

  $('#sl_county select').prop('selectedIndex',0);

  //
  //  When a county is selected, update the profile to display
  //  

  $('#sl_county select').change(function(){
    $('#profile img').attr('src',"img/" + $('#sl_county select').find(':selected').val() + ".jpg");
    $('#sl_county select').prop('selectedIndex',0);
  });
  
});
