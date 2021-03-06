package ru.agentlab.maia.memory.context.arrays.separated.test.blackbox

import java.util.ArrayList
import java.util.Collection
import org.junit.parameterizedsuite.ParameterizedSuite
import org.junit.runner.RunWith
import org.junit.runners.Parameterized.Parameters
import org.junit.runners.Suite.SuiteClasses
import ru.agentlab.maia.container.arrays.separated.SeparatedArraysContext
import ru.agentlab.maia.memory.context.test.blackbox.ServiceRegistrationExtension

@RunWith(ParameterizedSuite)
@SuiteClasses(#[ //	AbstractContext_removeByClass_FunctionalTests,
//	AbstractContext_removeByString_FunctionalTests,
//	AbstractContext_putServiceByClass_FunctionalTests,
//	AbstractContext_putServiceByString_FunctionalTests,
//	AbstractContext_putProviderByClass_FunctionalTests,
//	AbstractContext_putProviderByString_FunctionalTests
])
class SeparatedArraysContext_FunctionalTestSuite {

	@Parameters(name="implementation: [{0}], context:[{1}], parent:[{2}]")
	def public static Collection<?> keysAndValues() {
		val result = new ArrayList
		for (pair : ServiceRegistrationExtension.combinations) {
			result += #[new SeparatedArraysContext, pair.key, pair.value].toArray
		}
		return result
	}

}
