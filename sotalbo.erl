-module(sotalbo).
-compile(export_all).

server_chat() ->
  Name = string:strip(io:get_line("Enter your name: "), right, $\n),
  register(receiveMessage, spawn(sotalbo_erlang, receiveMessage, [])),
  sendMessage(Name).

receiveMessage() ->
  receive
    {sendMessage, SenderNode, SenderName, SenderMessage} ->
      case SenderMessage of
      "bye" ->
        io:format("Chat >>> ~s has said goodbye and is therefore disconnected.~n", [SenderName]),
        erlang:disconnect_node(SenderNode),
        receiveMessage();
      _ ->
        io:format("~s >>> ~s~n", [SenderName, SenderMessage]),
        receiveMessage()
      end
  end.

sendMessage(Name) ->
  InputName = Name ++ " >>> ",
  Message = string:strip(io:get_line(InputName), right, $\n),
  if
    Message == "bye" ->
      [Head | _] = nodes(),
      {receiveMessage, Head} ! {sendMessage, self(), Name, Message};
    true ->
      [Head | _] = nodes(),
      {receiveMessage, Head} ! {sendMessage, self(), Name, Message},
      sendMessage(Name)
  end.

client_chat(ServerNode) ->
  net_adm:ping(ServerNode),
  Name = string:strip(io:get_line("Enter your name: "), right, $\n),
  register(receiveMessage, spawn(sotalbo_erlang, receiveMessage, [])),
  sendMessage(Name).
