package ru.agentlab.maia.container

import java.lang.annotation.Annotation
import java.lang.reflect.Constructor
import java.lang.reflect.Field
import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import java.lang.reflect.Parameter
import java.util.ArrayList
import java.util.UUID
import java.util.concurrent.ConcurrentSkipListSet
import java.util.concurrent.atomic.AtomicReference
import javax.annotation.PostConstruct
import javax.inject.Inject
import javax.inject.Named
import org.eclipse.xtend.lib.annotations.Accessors
import ru.agentlab.maia.IContainer
import ru.agentlab.maia.context.exception.MaiaContextKeyNotFound
import ru.agentlab.maia.context.exception.MaiaInjectionException

/**
 * <p>
 * Abstract {@link IContainer} implementation.
 * </p>
 * <p>Implementation guarantee that:
 * </p>
 * <ul>
 * <li>Context can have parent;</li>
 * <li>Context have unique UUID;</li>
 * <li>Context redirect service searching to parent if can't find it;</li>
 * <li>Context disable <code>null</code> keys for storing services;</li>
 * </ul>
 * 
 * @author Dmitry Shishkin
 */
abstract class Container implements IContainer {

	@Accessors
	val private uuid = UUID.randomUUID.toString

	var protected parent = new AtomicReference<IContainer>(null)

	val protected childs = new ConcurrentSkipListSet<IContainer>

	override getParent() {
		return parent.get
	}

	override get(String key) {
		key.check
		try {
			return getInternal(key)
		} catch (MaiaContextKeyNotFound e) {
			val p = parent.get
			if (p != null) {
				return p.get(key)
			} else {
				throw new MaiaContextKeyNotFound(
					'''Service for key [«key»] did not found in context [«this.toString»] and all their parents'''
				)
			}
		}
	}

	override <T> get(Class<T> key) {
		key.check
		try {
			return getInternal(key) as T
		} catch (MaiaContextKeyNotFound e) {
			val p = parent.get
			if (p != null) {
				return p.get(key)
			} else {
				throw new MaiaContextKeyNotFound(
					'''Service for key [«key»] did not found in context [«this.toString»] and all their parents'''
				)
			}
		}
	}

	override getLocal(String key) {
		key.check
		return getInternal(key)
	}

	override <T> getLocal(Class<T> key) {
		key.check
		return getInternal(key) as T
	}

	override put(String key, Object value) {
		key.check
		return putInternal(key, value)
	}

	override <T> put(Class<T> key, T value) {
		key.check
		return putInternal(key, value)
	}

	override remove(String key) {
		key.check
		return removeInternal(key)
	}

	override remove(Class<?> key) {
		key.check
		return removeInternal(key)
	}

	override setParent(IContainer container) {
		parent.getAndSet(container)
	}

	override getChilds() {
		return childs
	}

	override addChild(IContainer container) {
		childs += container
		container.parent = this
	}

	override removeChild(IContainer container) {
		childs -= container
		container.parent = null
	}

	override clearChilds() {
		childs.forEach[parent = null]
		childs.clear
	}

	def protected Object getInternal(String key)

	def protected Object getInternal(Class<?> key)

	def protected Object putInternal(String key, Object value)

	def protected Object putInternal(Class<?> key, Object value)

	def protected Object removeInternal(String key)

	def protected Object removeInternal(Class<?> key)

	def private check(String key) {
		if (key == null) {
			throw new IllegalArgumentException("Key must be not null")
		}
	}

	def private check(Class<?> key) {
		if (key == null) {
			throw new IllegalArgumentException("Key must be not null")
		}
	}

	override <T> T make(Class<T> clazz) {
		try {
			val sortedConstructors = (clazz.constructors as Constructor<T>[]).sortWith [
				return $0.parameterTypes.length.compareTo($1.parameterTypes.length)
			]

			for (constructor : sortedConstructors) {
				val instance = constructor.tryConstruct
				if (instance != null) {
					return instance
				}
			}
			throw new MaiaInjectionException("Could not find satisfiable constructor in " + clazz.name) // $NON-NLS-1$
		} catch (NoClassDefFoundError e) {
			throw new MaiaInjectionException(e)
		} catch (NoSuchMethodError e) {
			throw new MaiaInjectionException(e)
		}
	}

//	def private invoke(Object object, Class<? extends Annotation> qualifier) {
//		val method = object.class.declaredMethods.findFirst[isAnnotationPresent(qualifier)]
//		return object.invoke(method, false, null)
//	}

//	override invoke(Object object, String methodName) {
//		val method = object.class.declaredMethods.findFirst[it.name == name]
//		return object.invoke(method, false, null)
//	}
//
//	override invoke(Object object, Method method) {
//		return object.invoke(method, false, null)
//	}
//
	def private invoke(Object object, Class<? extends Annotation> qualifier,
		Object defaultValue) throws MaiaInjectionException {
		val method = object.class.declaredMethods.findFirst[isAnnotationPresent(qualifier)]
		return object.invoke(method, true, defaultValue)
	}
//
//	override invoke(Object object, String methodName, Object defaultValue) {
//		val method = object.class.declaredMethods.findFirst[it.name == name]
//		return object.invoke(method, true, defaultValue)
//	}
//
//	override invoke(Object object, Method method, Object defaultValue) {
//		return object.invoke(method, true, defaultValue)
//	}

	def protected invoke(Object object, Method method, boolean haveDefault, Object defaultValue) {
		if (method == null && haveDefault) {
			return defaultValue
		}
		val values = resolveValues(resolveKeys(method.parameters))
		if (values.length < method.parameters.size) {
			if (haveDefault) {
				return defaultValue
			} else {
				throw new MaiaInjectionException
			}
		}
		var Object result = null
		var wasAccessible = true
		if (!method.accessible) {
			method.setAccessible(true)
			wasAccessible = false
		}
		try {
			result = method.invoke(object, values)
		} catch (IllegalArgumentException e) {
			if (haveDefault) {
				return defaultValue
			} else {
				throw new MaiaInjectionException(e)
			}
		} catch (IllegalAccessException e) {
			if (haveDefault) {
				return defaultValue
			} else {
				throw new MaiaInjectionException(e)
			}
		} catch (InvocationTargetException e) {
			if (haveDefault) {
				return defaultValue
			} else {
				throw new MaiaInjectionException(e)
			}
		} finally {
			if (!wasAccessible)
				method.setAccessible(false)
			clearArray(values)
		}
		return result
	}

	override void inject(Object object) throws MaiaInjectionException {
		if (object == null) {
			throw new NullPointerException
		}
		val fields = object.class.declaredFields.filter[isAnnotationPresent(Inject)]
		val keys = resolveKeys(fields)
		val values = resolveValues(keys)
		if (values.length < fields.size) {
			throw new MaiaInjectionException("Unresolved value for type " + keys.get(values.size))
		}
		for (i : 0 ..< fields.length) {
			val field = fields.get(i)
			val value = values.get(i)
			var wasAccessible = true
			if (!field.accessible) {
				field.setAccessible(true)
				wasAccessible = false
			}
			field.set(object, value)
			if (!wasAccessible) {
				field.setAccessible(false)
			}
		}
	}

	/**
	 * PostConstruct method is invoked before registration service in context.
	 * Services can remove old services from context in PostConstruct method.
	 */
	override <T> deploy(Class<T> serviceClass) throws MaiaInjectionException {
		val service = make(serviceClass)
		inject(service)
		invoke(service, PostConstruct, null)
		put(serviceClass, service)
		return service
	}

	override deploy(Object service) throws MaiaInjectionException {
		inject(service)
		invoke(service, PostConstruct, null)
		put(service.class.name, service)
		return service
	}

	override <T> deploy(Class<T> serviceClass, String key) throws MaiaInjectionException {
		val service = make(serviceClass)
		inject(service)
		invoke(service, PostConstruct, null)
		put(key, service)
		return service
	}

	override <T> deploy(Class<? extends T> serviceClass, Class<T> interf) throws MaiaInjectionException {
		val service = make(serviceClass)
		inject(service)
		invoke(service, PostConstruct, null)
		put(interf, service)
		return service
	}

	override deploy(Object service, String key) throws MaiaInjectionException {
		inject(service)
		invoke(service, PostConstruct, null)
		put(key, service)
		return service
	}

	override <T> deploy(T service, Class<T> interf) throws MaiaInjectionException {
		inject(service)
		invoke(service, PostConstruct, null)
		put(interf, service)
		return service
	}

	/**
	 * Don't hold on to the resolved results as it will prevent 
	 * them from being garbage collected. 
	 */
	def protected void clearArray(Object[] args) {
		if (args == null) {
			return
		}
		for (i : 0 ..< args.length) {
			args.set(i, null)
		}
	}

	def protected <T> T tryConstruct(Constructor<T> constructor) {
		if (!constructor.isAnnotationPresent(Inject) && constructor.parameterTypes.length != 0) {
			return null
		}
		val params = constructor.parameters
		val keys = resolveKeys(params)
		var Object[] values
		try {
			values = resolveValues(keys)
		} catch (MaiaContextKeyNotFound e) {
			return null
		}
		var T result = null
		var wasAccessible = true
		if (!constructor.accessible) {
			constructor.setAccessible(true)
			wasAccessible = false
		}
		try {
			result = constructor.newInstance(values)
		} catch (IllegalArgumentException e) {
			throw new MaiaInjectionException(values.toString + " " + constructor.parameterTypes, e)
		} catch (InstantiationException e) {
			throw new MaiaInjectionException("Unable to instantiate " + constructor, e) // $NON-NLS-1$
		} catch (IllegalAccessException e) {
			throw new MaiaInjectionException(e)
		} catch (InvocationTargetException e) {
			throw new MaiaInjectionException(e)
		} finally {
			if (!wasAccessible) {
				constructor.setAccessible(false)
			}
			clearArray(values)
		}
		return result
	}

	def protected Object[] resolveKeys(Parameter[] parameters) {
		val Object[] result = newArrayOfSize(parameters.length)
		parameters.forEach [ p, i |
			if (p.isAnnotationPresent(Named)) {
				val name = p.getAnnotation(Named).value
				result.set(i, name)
			} else {
				result.set(i, p.type.boxedType)
			}
		]
		return result
	}

	def protected Object[] resolveKeys(Field[] fields) {
		val injectFields = fields.filter[isAnnotationPresent(Inject)]
		val Object[] result = newArrayOfSize(injectFields.length)
		injectFields.forEach [ p, i |
			if (p.isAnnotationPresent(Named)) {
				val name = p.getAnnotation(Named).value
				result.set(i, name)
			} else {
				result.set(i, p.type.boxedType)
			}
		]
		return result
	}

	def protected getBoxedType(Class<?> type) {
		switch (type) {
			case byte: {
				return Byte
			}
			case short: {
				return Short
			}
			case int: {
				return Integer
			}
			case long: {
				return Long
			}
			case float: {
				return Float
			}
			case double: {
				return Double
			}
			case char: {
				return Character
			}
			case boolean: {
				return Boolean
			}
			default: {
				return type
			}
		}
	}

	def protected Object[] resolveValues(Object[] keys) throws MaiaContextKeyNotFound {
		val result = new ArrayList<Object>
		keys.forEach [
			switch (it) {
				String: {
					result += get(it)
				}
				Class<?>: {
					result += get(it)
				}
				default: {
					throw new MaiaContextKeyNotFound
				}
			}
		]
		return result.toArray
	}

}
