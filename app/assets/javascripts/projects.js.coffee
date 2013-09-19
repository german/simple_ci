$ ->
  $(".run_project").on "ajax:success", (e, data, status, xhr) ->
    $('.last_build').show()
    $('.last_build .progress').show()
    progressTimer = setInterval () ->
      $.getJSON '/projects/1/check_status', (response) ->
        console.log(response)
        clearInterval(progressTimer) if response.status == 'success' || responce.status == 'failed'
    , 500