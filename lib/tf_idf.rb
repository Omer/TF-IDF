class TfIdf
  def initialize(data, sparse=false)
    @sparse = sparse
    @data = data
  end
  
  def tf
    @tf ||= calculate_term_frequencies
  end
  
  def idf
    @idf ||= calculate_inverse_document_frequency
  end
  
  # This is basically calculated by multiplying tf by idf
  def tf_idf
    tf_idf = tf.map(&:clone)
    
    tf.each_with_index do |document, index|
      document.each_pair do |term, tf_score|
        tf_idf[index][term] = tf_score * idf[term]
      end
    end
    
    tf_idf
  end
    
  private
  
  def total_documents
    @data.size.to_f
  end
  
  # Returns all terms, once
  def terms
    @sparse ? @data.map(&:keys).flatten : @data.map(&:uniq).flatten
  end
  
  # IDF = total_documents / number_of_document_term_appears_in
  # This calculates how important a term is.
  def calculate_inverse_document_frequency
    results = Hash.new {|h, k| h[k] = 0 }

    terms.each do |term|
      results[term] += 1
    end

    log_total_count = Math.log10(total_documents)
    results.each_pair do |term, count|
      results[term] = log_total_count - Math.log10(count)
    end

    results.default = nil
    results
  end
  
  # TF = number_of_n_term_in_document / number_of_terms_in_document
  # Calculates the number of times a term appears in the document
  # It is then normalized (as some documents are longer than others)
  def calculate_term_frequencies
    results = []
    
    @data.each do |document|
      document_result = Hash.new {|h, k| h[k] = 0 }
      document_size = @sparse ? document.values.inject(&:+).to_f : document.size.to_f

      if @sparse
        document_result = document
      else
        document.each do |term|
          document_result[term] += 1
        end
      end
      # Normalize the count
      document_result.each_key do |term|
        document_result[term] /= document_size
      end
      
      results << document_result
    end
    
    results
  end
end
