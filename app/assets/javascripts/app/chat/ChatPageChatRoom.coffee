{ Alert, Icon } = antd

module.exports = ChatRoom = React.createClass
  render: ->
    <div className='chat-room'>
      <Header {...@props} />
      <ChatList {...@props} />
      <ChatInputer {...@props} />
    </div>

Header = React.createClass
  render: ->
    if @props.with_member
      <div className='header'>
        <span className='info member-info'><FaIcon type='user' /> {@props.with_member.name}</span>
      </div>
    else if @props.with_org
      <div className='header'>
        <span className='info org-info'><FaIcon type='circle-o' /> {@props.with_org.name}</span>
        <div className='members'>
          <Icon type='team' /> {@props.with_org.members.length}
        </div>
      </div>

ChatList = React.createClass
  getInitialState: ->
    messages: []

  render: ->
    <div className='chat-list'>
      <div className='channel-info'>
      {
        if @props.with_member
          <Alert message="你正在和 @#{@props.with_member.name} 单聊" type="info" />
        else if @props.with_org
          <Alert message="你正在组织机构 @#{@props.with_org.name} 中群聊" type="info" />
      }
      </div>
      {
        for message in @state.messages
          <ChatItem key={message.id} message={message} />
      }
    </div>

  componentDidMount: ->
    jQuery(document)
      .off 'received-message'
      .on 'received-message', (evt, data)=>
        console.log 'received', data
        messages = @state.messages
        messages.push data
        @setState messages: messages


ChatItem = React.createClass
  render: ->
    # message = {
    #   id: '...'
    #   time: '...'
    #   talker: {
    #     member_id: '...'
    #     name: '...'
    #   }
    #   content: {
    #     text: '...'
    #   }
    # }

    message = @props.message
    astyle = {
      backgroundColor: color20(message.talker.member_id)
    }

    <div key={message.id} className='chat-item'>
      <div className='avatar-first-char' style={astyle}>{message.talker.name[0]}</div>
      <div className='m-content'>
        <div className='talker'>
          <span className='name'>{message.talker.name}</span>
          <span className='time'>{new Date(message.time).format('hh:mm:ss')}</span>
        </div>
        <div className='text'>{message.content.text}</div>
      </div>
    </div>


ChatInputer = React.createClass
  getInitialState: ->
    text: ''

  render: ->
    <div className='chat-inputer'>
      <textarea 
        placeholder='在这里说话~' 
        value={@state.text} 
        onChange={@change} 
        onKeyDown={@keydown}
      />
    </div>

  change: (evt)->
    @setState text: evt.target.value

  keydown: (evt)->
    if evt.which is 13
      evt.preventDefault()
      @speak()

  speak: ->
    return if jQuery.trim(@state.text) == ''

    content = {
      text: @state.text
    }
    @setState text: ''

    if @props.with_member
      receiver_id = @props.with_member.id
      App.room.speak_single receiver_id, content

    if @props.with_org
      org_id = @props.with_org.id
      App.room.speak_organization org_id, content
