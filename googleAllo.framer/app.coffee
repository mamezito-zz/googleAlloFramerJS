# written by Sergiy Voronov twitter.com/mamezito dribbble.com/mamezito

# thax to Marc Krenn for his support and amazing module
# https://medium.com/@marc_krenn/framerfirebase1-e7d13a939cf4

Utils.insertCSS('@import url(https://fonts.googleapis.com/icon?family=Material+Icons); @import url(http://fonts.googleapis.com/css?family=Roboto);  html, body, input{font-family: "Roboto", sans-serif!important;}  .material-icons{font-family: "Material Icons"; height:72px; text-align:center; line-height:72px; font-size:72px;} .title{font-size:51px; line-height:168px; padding-left:168px;} .timeStamp{ color:#425556; text-align:center; font-size:33px; line-height:50px;} .checkBox{width:45px; height:45px; line-height:45px; font-size:45px;} .reply,  .question{font-size:42px; padding:30px; line-height:48px; border-radius:45px;} .reply{background:#00ACC1; float:right; text-align:right;} .question{background:#5E35B1; float:left; text-align:left;} .replyWindow2{background: #fff; box-shadow: 1px 0px 9px 0px rgba(0,0,0,0.25); border-radius: 75px; padding:20px 200px 20px 160px;  line-height:101px; color:#000; width:100%; box-sizing:border-box; font-size:42px; color:#95AAB2;} .replyWindow{ padding:20px 200px 20px 160px;  line-height:101px; color:#000; width:100%; box-sizing:border-box; color:#95AAB2;}')


{TextLayer} = require 'TextLayer'
{InputField} = require 'InputField'
{Firebase} = require 'firebase'
arcMovement = require 'arcMovement'



firebase = new Firebase
	projectID: "chat-demo-4531a"
	secret: "ghtPldIn2qnDgyT1yXS3ub7x1HMj5wco0IcOx23l"
	server: "s-usc1c-nss-126.firebaseio.com"

color=Utils.randomChoice(["#7BB135","#00ACC1","#5E35B11","#35B1A1","#007EC1","#C1C100"])
darkColor=new Color(color).lighten(20)

currentUser=" "
canSend=false
dragstart=false
canLogin=false


class avatar extends Layer
	constructor: (opts)->
		super opts
		@width=100
		@height=100
		@borderRadius=100
		@html=opts.userName.charAt(0)
		@style=
			"width":"100px"
			"text-align":"center"
			"line-height":"100px"
			"font-size":"36px"
			"text-transform":"uppercase"
			"background-image": "linear-gradient(-180deg,"+opts.color1+" 0%,"+opts.color2+" 100%)"
			


class message extends TextLayer
	constructor: (opts)->
# 		super opts
		childarray=opts.parent.children
		if childarray[0]
			posY=childarray[childarray.length-1].maxY+20
		else
			posY=0
		
		message= new TextLayer
			fontSize:opts.fontSize
			autoSize:true
			text:opts.text
			color:"fff"
			padding:30
			borderRadius:45
			y:posY
			superLayer:opts.parent
			backgroundColor:opts.firstColor
		
		if opts.user==currentUser
			message.maxX=Screen.width-70
			checkBoxIcon = new Layer
				height: 45
				width: 45
				backgroundColor:"null"
				color:opts.firstColor
				html:"<i class='material-icons checkBox'>check_circle</i>"
				parent:message
				maxY: message.height
				maxX:message.width+50
				opacity:0
			checkBoxIcon.style="line-height":"45px"
			Utils.delay 0.2,->
				checkBoxIcon.animate
					properties:
						opacity:1
		else 
			message.x=165
			secondColor=new Color(opts.firstColor).lighten(20)
			userPic=new avatar
				parent:message
				userName:opts.user
				name:"avatars"
				color1:opts.firstColor
				color2:secondColor
				x:-120
				y:0
			
		message.originY=1
		message.originX=1
		message.scale=0
		message.opacity=1

		message.animate
			properties:
				scale:1
				opacity:1
				y:opts.y
			time:0
# 			curve: "spring(300,15,0)"



backgroundA = new BackgroundLayer
	image: "images/bg.png"



chatScreen=new Layer
	width:Screen.width
	height:Screen.height
	backgroundColor: "null"
	x:Screen.width
chatScreen.states.add
	active:
		x:0
scroll = new ScrollComponent
	width: Screen.width
	height: Screen.height
	scrollHorizontal: false
	parent:chatScreen
	clip:true
scroll.content.backgroundColor="null"
scroll.contentInset=
	bottom:181
	top:200
replyWindow = new Layer
	parent:chatScreen
	maxY: Screen.height-15
	height:141
	width: Screen.width-30
	backgroundColor: "null"
	
replyText=new Layer
	parent:replyWindow
	width:replyWindow.width
	backgroundColor: "null"
	height:141
	html:"<div class='replyWindow'><div style='width:630px; margin:0 auto;'>Type something</div><div>"	
	
replyText.style.fontSize="42px"
replyShadow=new Layer
	parent:replyWindow
	shadowBlur: 9
	borderRadius: 141/2
	backgroundColor: "white"
	shadowColor: "rgba																														(0,0,0,0.35)"
	width:replyWindow.width
	height:replyWindow.height
	

replyShadow.sendToBack()
replyWindow.centerX()

plusIcon = new Layer
	height: 72
	width: 72
	backgroundColor:"null"
	color:"#2B99CA"
	html:"<i class='material-icons'>add</i>"
	parent:replyWindow
	x:48
plusIcon.centerY()

micIcon = new Layer
	height: 72
	width: 72
	backgroundColor:"null"
	color:"#7193B1"
	html:"<i class='material-icons'>mic</i>"
	parent:replyWindow
	maxX:replyWindow.width-48
	y:34
micIcon.centerY()
micIcon.states.add
	active:
		opacity:0
slider=new Layer
	width:90
	borderRadius: 60
	height:600
	backgroundColor: "#4696dd"
	superLayer: replyWindow
	maxY:replyWindow.height
	x:replyWindow.width-130
	opacity:0
slider.states.add
	active:
		opacity:1
sendIcon = new Layer
	height: 72
	width: 72
	backgroundColor:"null"
	color:"#7193B1"
	html:"<i class='material-icons'>send</i>"
	opacity:0
	brightness : 100
	parent:replyWindow
	maxX:replyWindow.width-48
	y:34
sendIcon.centerY()
sendIcon.states.add
	active:
		opacity:1
		brightness : 100
		y:34
	pressed:
		opacity:1
		brightness : 1000
sendIcon.draggable=false
sendIcon.draggable.horizontal=false
sendIcon.draggable.constraints=
	x:sendIcon.x
	y:sendIcon.maxY-540
	width:sendIcon.x
	height:540
sendIcon.draggable.overdrag = false


smileIcon = new Layer
	height: 72
	width: 72
	backgroundColor:"null"
	color:"#7193B1"
	html:"<i class='material-icons'>tag_faces</i>"
	parent:replyWindow
	maxX:replyWindow.width-148
smileIcon.centerY()

header = new Layer
	y: 0
	height:168
	backgroundColor:"rgba(255,255,255,0.95)"
	width: Screen.width
	color:"#7193B1"
	html:"<div class='title'>Group chat</div>"
	shadowBlur: 10
	shadowColor: "rgba(0,0,0,0.15)"
	shadowY:4
	parent:chatScreen

backIcon = new Layer
	height: 72
	width: 72
	backgroundColor:"null"
	color:"#7193B1"
	html:"<i class='material-icons'>arrow_back</i>"
	parent:header
	x:45
backIcon.centerY()





replyInput = new InputField
	name:"myInput"
	maxY: Screen.height-15
	height:141
	width: Screen.width-450
	backgroundColor: "null"
	parent:chatScreen
	maxLength: 30
	x:170
replyInput.on Events.Focus, (value, layer) ->
	replyWindow.bringToFront()
	replyText.html="<div class='replyWindow'><div style='width:630px; margin:0 auto;'>"+value+"</div><div>"

replyInput.on Events.Input, (value, layer) ->
	canSend=true
	sendIcon.draggable=true
	sendIcon.states.switch("active")
	micIcon.states.switch("active")
	replyText.html="<div class='replyWindow'><div style='width:630px; margin:0 auto;'>"+value+"</div><div>"
	


replyInput.on Events.Blur, (value, layer) ->
	if value==""
		sendIcon.draggable=false
		sendIcon.states.switch("default")
		micIcon.states.switch("default")
		replyText.html="<div class='replyWindow'><div style='width:630px; margin:0 auto;'>Type something</div><div>"

bubblefontSize=42

sendIcon.onClick ->
	if !dragstart
		if canSend
			sendMessage()
sendIcon.onDragEnd ->
	dragstart=false
	sendMessage()
	replyShadow.animate
		properties:
			height:141
			y:0
		time:0.2
	
sendMessage =  ->#
	if color=="null" or color=="#5E35B11"
		color="#35B1A1"
	firebase.post("/message", { 
		"text" : replyInput.value
		"fontSize":bubblefontSize
		"user":currentUser
		"firstColor":color
		})
	replyInput.clear()
	replyText.html="<div class='replyWindow'><div style='width:630px; margin:0 auto;'>Type something</div><div>"
	bubblefontSize=42
	replyText.style.fontSize="#{bubblefontSize}px"
	sendIcon.states.switch("default")
	micIcon.states.switch("default")
	slider.states.switch("default")
	canSend=false
	replyText.y=0

sendIcon.onDragStart ->
	dragstart=true
	slider.states.switch("active")
	sendIcon.states.switch("pressed")
sendIcon.onDrag ->
	bubblefontSize=Utils.modulate(this.y, [34, -494], [42, 100],  true)
	
	replyText.style.fontSize="#{bubblefontSize}px"
	replyText.y=Utils.modulate(this.y, [134, -494], [0, -50],  true)
	replyShadow.maxY=141
	replyShadow.height=Utils.modulate(this.y, [134, -494], [141, 220],  true)



response = (data, method, path, breadCrumb) ->
	if path=="/"
		messagesArray= _.toArray(data.message)
		number=messagesArray.length-50
		messagesArray.splice(0,number)
		for messageItem in messagesArray
# 			type="question"
			text=new message
				text:messageItem.text
				user:messageItem.user
				fontSize:messageItem.fontSize
				firstColor:messageItem.firstColor
				fontSize:messageItem.fontSize
				parent:scroll.content
				
			scroll.updateContent()
	else
# 		type="answer"
		text=new message
			text:data.text
			user:data.user
			fontSize:data.fontSize
			parent:scroll.content
			firstColor:data.firstColor
		scroll.updateContent()
	messagesShown=scroll.content.children
	if messagesShown[messagesShown.length-1].screenFrame.y>Screen.height-300
		scroll.scrollToLayer(messagesShown[messagesShown.length-1])



	
	

Events.wrap(window).addEventListener "keydown", (event) ->
	if event.keyCode is 13
		if canSend
			sendMessage()
		else if canLogin
			login()
			

currentAvatar=new avatar
	userName:""
	
	name:"avatars"
	color1:color
	color2:darkColor
	scale:2
	y:Screen.height*0.32

currentAvatar.centerX()

loginHolder=new Layer
	width:Screen.width-450
	height:141
	backgroundColor:"null"
	x:0
loginHolder.states.add
	logged:
		x:-Screen.width
loginHolder.center()
loginLabel=new TextLayer
	fontSize:58
	autoSize:true
	text:"Your name"
	color:"#666"
	backgroundColor:"null"
	y:40
	scale:1
	superLayer:loginHolder
	originX:0
loginLabel.states.add
	active:
		scale:0.8
		x:0
		y:-50
		color:"#ccc"
loginButton= new Layer
	width:Screen.width-550
	height:141
	y: 200
	backgroundColor: "#9FC100"
	borderWidth: 1
	borderRadius: 141
	color:"white"
	html:"LOGIN"
	opacity:0
	parent:loginHolder
loginButton.states.add
	active:
		opacity:1
loginButton.style=
	"text-align":"center"
	"line-height":"141px"
	"font-size":"48px"
	
loginButton.centerX()
nameInput = new InputField
	name:"nameInput"
	fontSize: 58
	height:141
	width: Screen.width-450
	parent:loginHolder
	fontFamily: "Roboto"
	placeHolder: ""
	backgroundColor: "null"
nameInput.style=
	"border-bottom":"3px solid #ccc"

nameInput.on Events.Focus, (value, layer) ->
	loginLabel.states.switch("active", time: 0.2, curve: "ease")
	

nameInput.on Events.Blur, (value, layer) ->
	if value==""
		loginLabel.states.switch("default", time: 0.2, curve: "ease")
		loginButton.states.switch("default", time: 0.2, curve: "ease")

nameInput.on Events.Input, (value, layer) ->
	currentAvatar.html=value.charAt(0)
	canLogin=true
	loginButton.states.switch("active", time: 0.2, curve: "ease")

loginButton.onClick ->
	if canLogin
		login()


login =->
	currentUser=nameInput.value
	loginHolder.states.switch("logged", time: 0.2, curve: "ease")
	chatScreen.states.switch("active", time: 0.2, curve: "ease")
	currentAvatar.animate
		properties:
			scale:1
		time: 0.2
		curve: "ease"
	arcMovement.moveWithArc currentAvatar, currentAvatar.x,currentAvatar.y, Screen.width-80, 80
	firebase.onChange("/", response)
	


