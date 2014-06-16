@GamePlayCtrl = ($scope, $location, $http, $routeParams, $q, scriptData) ->

  $scope.typos = 0
  $scope.counter = 0
  $scope.totalKeypress = 0
  $scope.startTime = new Date()
  $scope.endTime
  $scope.time_elapsed
  $scope.CPS
  $scope.charList
  $scope.missedChars = []
  $scope.finished = false
  $scope.mostMissedChar
  $scope.missedTimes

  $scope.script =
    currentScript:
      text: 'Loading...'
      id: ''

  $scope.scriptId = $routeParams.scriptId

  prepScriptData = ->
    script = _.findWhere(scriptData.data.scripts, { id: parseInt($scope.scriptId) })
    $scope.script.currentScript.text = script.text
    $scope.script.currentScript.id = script.id
    $scope.charList = $scope.script.currentScript.text.split ""
  # Create promise to be resolved after posts load
  @deferred = $q.defer()
  @deferred.promise.then(prepScriptData)

  # Provide deferred promise chain to the loadPosts function
  scriptData.getScripts(@deferred)

# --Game Play ------------------------

  sendData = ->
    $scope.cps = ($scope.totalKeypress / (($scope.endTime - $scope.startTime)/1000))
    $scope.time_elapsed = new Date( ($scope.endTime - $scope.startTime) )
    # Create data object to POST
    completionData =
      new_performance:
        number_missed: $scope.typos
        total_characters: $scope.charList.length
        time_elapsed: $scope.time_elapsed
        wpm: $scope.cps
        script_id: $scope.scriptId
        missed_characters: $scope.missedChars.toString()

    # Do POST request to /posts.json
    $http.post('./performances.json', completionData).success( (data) ->
      $scope.mostMissedChar = data.character.toString()
      $scope.missedTimes = data.times.toString()
      console.log("Successfully sent data.")
    ).error( ->
      console.error('Failed to create new post.')
    )
    
    # Log the data
    $scope.finished = true
    console.log("Total Keypress: " + $scope.totalKeypress)
    console.log("Total $scope.charList.length: " + $scope.charList.length)
    console.log("$scope.typos:" + $scope.typos)
    console.log("Total time: " + $scope.time_elapsed)
    console.log("Total $scope.CPS(chars per second): " + $scope.cps)
    console.log("Missed characters: " + $scope.missedChars)

  markRed = ->
    $(".cursor").css("color", "red")

  moveCursor = ->
    if $scope.counter == 0
      $("code span:first").removeClass('cursor untyped')
    else
      $("code span:nth-child("+$scope.counter+")").removeClass('untyped cursor')
    $("code span:nth-child("+($scope.counter+1)+")").addClass('cursor typed')

  # $scope.getChars = ->
  #   $scope.charList = $scope.script.currentScript.text.split ""

  $scope.restart = (scriptId) ->
    console.log(scriptId)
    $location.url('/gameplay/' + scriptId)

  isComplete = ->
    if $scope.counter == $scope.charList.length
      $scope.endTime = new Date()
      sendData()
    
  newCheck = (keypress) ->
    if keypress == $scope.charList[$scope.counter]
      $scope.counter++
      moveCursor()
    else
      $scope.typos++
      markRed()
      $scope.missedChars.push(characters[$scope.counter])

  $scope.listen = (event) ->
    event.preventDefault()
    $scope.totalKeypress++;
    newCheck( String.fromCharCode(event.which) );      
    isComplete()

  $scope.start = ->
    $("code span:first").addClass('cursor')
    $('button').hide()
    $scope.$on "my:keypress", (event, keyEvent) ->
      $scope.listen(keyEvent)

@GamePlayCtrl.$inject = ['$scope', '$location', '$http', '$routeParams', '$q', 'scriptData']