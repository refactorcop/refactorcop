module ApplicationHelper
  
  def random_quote
    
    quotes = Array[
      "Dead or alive, you're coming with me!",
      "Your move, creep.",
      "Serve the public trust, protect the innocent, uphold the law.",
      "Come quietly or there will be... trouble.",
      "Stay out of trouble.",
      "They'll fix you. They fix everything.",
      "Thank you for your cooperation. Good night.",
      "Madame, you have suffered an emotional shock. I will notify a rape crisis center.",
      "Madame, you have suffered an emotional shock. I will notify a rape crisis center.",
      "Looking for me?",
      "Excuse me, I have to go. Somewhere there is a crime happening.",
      "I'm not arresting you anymore."
    ]
    
    quotes[ rand( quotes.length ) ]
    
  end
end
