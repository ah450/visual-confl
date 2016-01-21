###
A directive for representing a critical pair
###

angular.module 'vconfl'
  .directive 'pairGraph', (Node) ->
    

    representConstraint = (constraint) ->
      constraint.name

    representConstraintStore = (store) ->
      representedConstraints = store.map representConstraint
      return "#{representedConstraints.join(', ')}"

    setupCanvas = (element, ctx, scope) ->
      if window.devicePixelRatio
        scope.width = element.parent().width() * 0.8
        scope.height = $(window).height() * 0.8
        element.attr 'width', scope.width * window.devicePixelRatio
        element.attr 'height', scope.height * window.devicePixelRatio
        ctx.scale window.devicePixelRatio, window.devicePixelRatio

    drawRoot = (element, ctx, scope) ->
      representation = "Goals: #{representConstraintStore scope.pair.commonGoals} . Constraint store: #{representConstraintStore scope.pair.commonStore}."
      measurments = ctx.measureText representation
      diff = scope.width - measurments.width
      posX = 0
      posY = 12
      if diff > 0
        posX = diff / 2
      ctx.fillText representation, posX, posY
      scope.root = new Node posX, posY, measurments.width, 15

    measureDerivations = (element, ctx, derivations) ->
      nodes = []
      derivations.forEach (derivation) ->
        if derivation.action.type in ['propagate', 'simplify', 'initial']
          data =
            rule: derivation.action.rule.representation
            store: "Goals: #{representConstraintStore derivation.goals} . Constraint store: #{representConstraintStore derivation.store}."
          data.ruleMeasurements = ctx.measureText data.rule
          data.storeMeasurements = ctx.measureText data.store
          data.maxWidth = Math.max data.ruleMeasurements.width, data.storeMeasurements.width
          nodes.push data
      return nodes



    drawBranch = (element, ctx, scope, branch, leftOffset, rightOffset) ->
      ctx.beginPath()
      ctx.moveTo scope.root.center.x, scope.root.bottomLeft.y
      incline = Math.max(leftOffset, rightOffset) * Math.tan(30 * Math.PI/180)
      parent = new Node  -leftOffset + scope.root.x + rightOffset, scope.root.y, scope.root.width, incline
      ctx.lineTo parent.center.x, parent.bottomLeft.y
      ctx.stroke()
      for node in branch
        # Draw rule
        rStartX = parent.center.x - node.ruleMeasurements.width / 2
        rStartY = parent.bottomLeft.y + 12
        ctx.fillText node.rule, rStartX, rStartY
        # Draw line from rule
        lineStartY = rStartY + 5
        rHeightDiff = lineStartY - parent.bottomLeft.y
        ctx.beginPath()
        ctx.moveTo parent.center.x, lineStartY
        ctx.lineTo parent.center.x, lineStartY + rHeightDiff
        ctx.stroke()
        # Draw constraint store
        sStartX = parent.center.x - node.storeMeasurements.width / 2
        sStartY = lineStartY + rHeightDiff + 12
        ctx.fillText node.store, sStartX, sStartY
        nStartX = Math.min sStartX, rStartX
        nStartY = parent.bottomLeft.y
        nWidth = Math.max node.storeMeasurements.width, node.ruleMeasurements.width
        nHeight = sStartY + 5 - nStartY
        nParent = new Node nStartX, nStartY, nWidth, nHeight
        nParent.parent = parent
        parent = nParent
      return parent




    draw = (element, ctx, scope) ->
      ctx.font = '10px Source Code Pro'
      drawRoot element, ctx, scope
      leftMeasurements = measureDerivations element, ctx, scope.pair.derivationsFirst
      rightMeasurements = measureDerivations element, ctx, scope.pair.derivationsSecond
      maxLeftWidth = leftMeasurements.reduce (memo, value) ->
        Math.max memo, value.maxWidth
      , 0
      maxRightWidth = rightMeasurements.reduce (memo, value) ->
        Math.max memo, value.maxWidth
      , 0
      # Left is left of the canvas looking towards the screen viewer.
      # So left is screen viewer's right
      leftLeafNode = drawBranch element, ctx, scope, leftMeasurements, 0, maxRightWidth + 0.025 * scope.width
      rightLeafNode = drawBranch element, ctx, scope, rightMeasurements, maxLeftWidth + 0.025 * scope.width, 0
      if scope.pair.joinable
        # Clear left leaf
        ctx.clearRect leftLeafNode.x, leftLeafNode.y, leftLeafNode.width, leftLeafNode.height
        # Clear right leaf
        ctx.clearRect rightLeafNode.x, rightLeafNode.y, rightLeafNode.width, rightLeafNode.height
        leftParent = leftLeafNode.parent
        leftNode = leftMeasurements[leftMeasurements.length - 1]
        rightParent = rightLeafNode.parent
        rightNode = rightMeasurements[rightMeasurements.length - 1]
        # Draw left rule
        lrStartX = leftParent.center.x - leftNode.ruleMeasurements.width / 2
        lrStartY = leftParent.bottomLeft.y + 12
        ctx.fillText leftNode.rule, lrStartX, lrStartY
        # Draw right rule
        rrStartX = rightParent.center.x - rightNode.ruleMeasurements.width / 2
        rrStartY = rightParent.bottomLeft.y + 12
        ctx.fillText rightNode.rule, rrStartX, rrStartY
        storeStartX = scope.root.center.x - leftNode.storeMeasurements.width / 2
        storeStartY = Math.abs(lrStartX - rrStartX) * Math.tan(45 * Math.PI / 180)
        ctx.beginPath()
        ctx.moveTo lrStartX + leftNode.ruleMeasurements.width / 2, lrStartY + 5
        ctx.lineTo storeStartX, storeStartY
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo rrStartX + rightNode.ruleMeasurements.width / 2, rrStartY + 5
        ctx.lineTo storeStartX, storeStartY
        ctx.stroke()
        ctx.fillText rightNode.store, storeStartX - rightNode.storeMeasurements.width / 2, storeStartY + 12






    directive =
      restrict: 'A'
      scope:
        pair: '='
      link: (scope, element) ->
        console.log scope.pair.derivationsFirst[0]
        console.log scope.pair.derivationsSecond[0]
        console.log scope.pair
        ctx = element[0].getContext '2d'
        setupCanvas element, ctx, scope
        draw element, ctx, scope
        $(window).resize ->
          setupCanvas element, ctx, scope
          draw element, ctx, scope
        scope.$on '$destroy', ->
          $(window).off 'resize'
        
        


        
