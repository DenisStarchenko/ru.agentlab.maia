package ru.agentlab.maia.agent.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Repeatable;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import ru.agentlab.maia.agent.annotation.converter.OnBeliefXXXConverter;
import ru.agentlab.maia.agent.annotation.internal.HaveBeliefsClassAssertionAxiom;
import ru.agentlab.maia.converter.PlanEventFilterConverter;

@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@Repeatable(HaveBeliefsClassAssertionAxiom.class)
@PlanEventFilterConverter(OnBeliefXXXConverter.class)
public @interface HaveBeliefClassAssertionAxiom {

	String[] value() default { "?$1", "?$2" };

}