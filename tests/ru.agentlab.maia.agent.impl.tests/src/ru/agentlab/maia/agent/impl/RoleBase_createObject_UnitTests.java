package ru.agentlab.maia.agent.impl;

import org.junit.Test;
import org.junit.experimental.categories.Category;

import ru.agentlab.maia.tests.util.category.speed.QuickTests;
import ru.agentlab.maia.tests.util.category.type.UnitTests;
import ru.agentlab.maia.tests.util.category.visibility.WhiteBoxTests;

/**
 * Tests for {@link RoleBase#create(Object)}
 * 
 * @author Dmitriy Shishkin <shishkindimon@gmail.com>
 */
@Category({ UnitTests.class, QuickTests.class, WhiteBoxTests.class })
public class RoleBase_createObject_UnitTests extends RoleBaseAbstractTest {

	@Test(expected = NullPointerException.class)
	public void nullObject() {
		// Given
		Object objectRole = givenNullObject();
		// When
		whenCreate(objectRole);
	}

}
