$ ->
  $(".run_project").on "ajax:success", (e, data, status, xhr) ->
    $('.last_build').show()
    $('.last_build .progress').show()
    start_build_time = new Date().getTime()
    progressTimer = setInterval () ->
      $.getJSON '/projects/1/check_status', (response) ->
        # show progress of the build
        if response.reference_duration
          time_elapsed = new Date().getTime() - start_build_time
          progress = ((time_elapsed / 1000 / response.reference_duration) * 100.0)
          progress = 100.0 if progress > 100.0
          $('.last_build .progress .meter').css({width: (progress + '%')})
        
        if response.status == 'success' || response.status == 'failure'
          clearInterval(progressTimer)
          $('.last_build .progress').hide()
          $('.last_build .state').html(response.status)
          label_class = if response.status == 'success' then 'success' else 'alert'
          $('.last_build .label').addClass(label_class)
    , 500