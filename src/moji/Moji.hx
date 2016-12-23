package moji;

typedef Condition = moji.core.Condition;
typedef ConditionObject = moji.core.Condition.ConditionObject;

typedef Conditional<T> = moji.core.Conditional<T>;
typedef ConditionalObject<T> = moji.core.Conditional.ConditionalObject<T>;
typedef Maybe<T> = moji.core.Conditional.Maybe<T>;

typedef Engine<T> = moji.core.Engine<T>;

typedef Event = moji.core.Event;
typedef BasicEvent<T> = moji.core.Event.BasicEvent<T>;
typedef EventResult = moji.core.Event.EventResult;
typedef NextEvent = moji.core.Event.NextEvent;
typedef SubEvents = moji.core.Event.SubEvents;

typedef Prompt = moji.core.Prompt;
typedef Answer = moji.core.Prompt.Answer;

typedef Renderer = moji.core.Renderer;