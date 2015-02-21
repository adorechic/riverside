class PinboardControllerStylesheet < ApplicationStylesheet
  def url(st)
    st.text_alignment = :center
    st.keyboard_type = :alphabet
    st.font = font.medium
    st.frame = { l: 0, below_prev: 40, w: device_width, h: 100 }
    st.placeholder = 'url'
    st.return_key_type = :next
  end

  def title(st)
    st.text_alignment = :center
    st.keyboard_type = :alphabet
    st.font = font.medium
    st.frame = { l: 0, below_prev: 40, w: device_width, h: 100 }
    st.placeholder = 'title'
    st.return_key_type = :next
  end

  def tag(st)
    st.text_alignment = :center
    st.keyboard_type = :alphabet
    st.font = font.medium
    st.frame = { l: 0, below_prev: 40, w: device_width, h: 100 }
    st.placeholder = 'tags'
    st.return_key_type = :done
  end

  def submit_button(st)
    standard_button(st)
    st.frame = { l: 30, below_prev: 49, w: 100, h: 60 }
    st.font = font.large
    st.text = 'Save'
  end

  def root_view(st)
    st.background_color = color.white
  end
end
