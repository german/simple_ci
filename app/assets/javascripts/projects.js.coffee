$ ->
  $(".run_project").on "ajax:success", (e, data, status, xhr) ->
    $('.last_build').show()
    $('.last_build .progress').show()
    progressTimer = setInterval () ->
      $.getJSON '/projects/1/check_status', (response) ->
        if response.status == 'success' || response.status == 'failure'
          clearInterval(progressTimer)
          $('.last_build .progress').hide()
          $('.last_build .state').html(response.status)
          $('.last_build .label').addClass(response.status == 'success' ? 'success' : 'alert')
    , 500