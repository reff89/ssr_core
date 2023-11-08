-- Copyright (c) 2022-2023 Oneline/D.Borovsky
-- All rights reserved
addLineInChat = function(line, tabID)
    if isClient() then
        tabID = tabID or 0;
        if not ISChat.instance.chatText then
            ISChat.instance.chatText = ISChat.instance.defaultTab;
            ISChat.instance:onActivateView();
        end
        local chatText;
        for i,tab in ipairs(ISChat.instance.tabs) do
            if tab and tab.tabID == tabID then
                chatText = tab;
                break;
            end
        end
        if chatText.tabTitle ~= ISChat.instance.chatText.tabTitle then
            local alreadyExist = false;
            for i,blinkedTab in ipairs(ISChat.instance.panel.blinkTabs) do
                if blinkedTab == chatText.tabTitle then
                    alreadyExist = true;
                    break;
                end
            end
            if alreadyExist == false then
                table.insert(ISChat.instance.panel.blinkTabs, chatText.tabTitle);
            end
        end
        local vscroll = chatText.vscroll
        local scrolledToBottom = (chatText:getScrollHeight() <= chatText:getHeight()) or (vscroll and vscroll.pos == 1)
        if #chatText.chatTextLines > ISChat.maxLine then
            local newLines = {};
            for i,v in ipairs(chatText.chatTextLines) do
                if i ~= 1 then
                    table.insert(newLines, v);
                end
            end
            table.insert(newLines, line .. " <LINE> ");
            chatText.chatTextLines = newLines;
        else
            table.insert(chatText.chatTextLines, line .. " <LINE> ");
        end
        chatText.text = "";
        local newText = "";
        for i,v in ipairs(chatText.chatTextLines) do
            if i == #chatText.chatTextLines then
                v = string.gsub(v, " <LINE> $", "")
            end
            newText = newText .. v;
        end
        chatText.text = newText;
        local message = FakeMessage:new (line, nil)
        table.insert(chatText.chatMessages, message);
        chatText:paginate();
        if scrolledToBottom then
            chatText:setYScroll(-10000);
        end
    end
end

FakeMessage = {}

function FakeMessage:new (text, author)
	local o = {}
	o.text = text;
	o.author = author or nil
	
	function FakeMessage:getText()
		return self.text;
	end

	function FakeMessage:getAuthor()
		return self.author;
	end
	
	setmetatable(o, self)
	self.__index = self
	return o
end