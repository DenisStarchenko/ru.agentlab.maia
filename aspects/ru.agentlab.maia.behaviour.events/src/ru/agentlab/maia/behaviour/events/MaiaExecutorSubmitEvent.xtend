package ru.agentlab.maia.behaviour.events

import java.util.HashMap
import org.eclipse.xtend.lib.annotations.Accessors
import ru.agentlab.maia.event.IMaiaEvent

class MaiaExecutorSubmitEvent implements IMaiaEvent {

	val protected static String KEY_CONTEXT = "context"

	val public static String TOPIC = "ru/agentlab/maia/execution/Submit"

	@Accessors
	val data = new HashMap<String, Object>

//	new(IContext context) {
//		data.put(KEY_CONTEXT, context)
//	}
	override getTopic() {
		return TOPIC
	}

	def Object getContext() {
		return data.get(KEY_CONTEXT)
	}

}