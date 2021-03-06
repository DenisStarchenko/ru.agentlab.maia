package ru.agentlab.maia.context.arrays

import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import ru.agentlab.maia.context.arrays.test.whitebox.VariableSizeCotextTests
import ru.agentlab.maia.context.arrays.test.whitebox.doubles.DummyService

import static org.hamcrest.Matchers.*
import static org.junit.Assert.*

@RunWith(Parameterized)
class ArrayContextSetByStringTests extends VariableSizeCotextTests<ArrayContext> {

	@Accessors
	val context = new ArrayContext

	val service = new DummyService

	extension ArrayContextTestsExtension = new ArrayContextTestsExtension

	new(String[] keys, Object[] values) {
		context.keys = (keys)
		context.values = (values)
	}

	@Test
	def void shouldKeysAndValuesHaveSameSize() {
		context.put(DummyService.name, service)

		assertThat(context.keys.size, equalTo(context.values.size))
	}

	@Test
	def void shouldIncreaseSizeWhenNoValue() {
		context.prepareWithOutService(DummyService.name)
		val keysSizeBefore = context.keys.size
		val valuesSizeBefore = context.values.size

		context.put(DummyService.name, service)

		assertThat(context.keys.size - keysSizeBefore, equalTo(1))
		assertThat(context.values.size - valuesSizeBefore, equalTo(1))
	}

	@Test
	def void shouldNotIncreaseSizeWhenExistValue() {
		context.prepareWithService(DummyService.name, service)
		val keysSizeBefore = context.keys.size
		val valuesSizeBefore = context.values.size

		context.put(DummyService.name, service)

		assertThat(context.keys.size, equalTo(keysSizeBefore))
		assertThat(context.values.size, equalTo(valuesSizeBefore))
	}

	@Test
	def void shouldChangeWhenExistValue() {
		context.prepareWithService(DummyService.name, service)
		val keyIndex = context.keys.indexOf(DummyService.name)
		val newService = new DummyService

		context.put(DummyService, newService)

		assertThat(context.keys.get(keyIndex), equalTo(DummyService.name))
		assertThat(context.values.get(keyIndex) as DummyService, not(service))
		assertThat(context.values.get(keyIndex) as DummyService, equalTo(newService))
	}

	@Test
	def void shouldAddWhenNoValue() {
		context.prepareWithOutService(DummyService.name)

		context.put(DummyService.name, service)

		assertThat(context.keys.last, equalTo(DummyService.name))
		assertThat(context.values.last, is(instanceOf(DummyService)))
		assertThat(context.values.last as DummyService, equalTo(service))
	}

	@Test
	def void shouldKeyEqualsToName() {
		context.prepareWithOutService(DummyService.name)
		context.put(DummyService.name, service)
		val keyIndex = context.keys.indexOf(DummyService.name)

		assertThat(context.keys.get(keyIndex), equalTo(DummyService.name))
	}

}